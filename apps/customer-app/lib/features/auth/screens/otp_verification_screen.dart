import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../location/providers/address_provider.dart';
import '../providers/auth_provider.dart';

/// 6-digit OTP verification screen with resend cooldown, change-number action,
/// and development-only OTP display when provided by the backend.
class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String countryCode;
  final int initialCooldownSeconds;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.countryCode = '+91',
    this.initialCooldownSeconds = 30,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpCtrl = TextEditingController();
  late int _resendSecondsLeft;
  Timer? _resendTimer;
  bool _verifyingOrNavigating = false;

  @override
  void initState() {
    super.initState();
    _startResendCountdown(widget.initialCooldownSeconds);
  }

  void _startResendCountdown(int seconds) {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = seconds.clamp(1, 120));
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendSecondsLeft <= 1) {
        t.cancel();
        setState(() => _resendSecondsLeft = 0);
      } else {
        setState(() => _resendSecondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

  String _formattedPhone() {
    final p = widget.phone;
    if (widget.countryCode == '+91' && p.length == 10) {
      return '+91 ${p.substring(0, 5)} ${p.substring(5)}';
    }
    if (p.startsWith('+')) return p;
    return '${widget.countryCode} $p';
  }

  Future<void> _verify() async {
    if (_verifyingOrNavigating) return;
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) return;

    _verifyingOrNavigating = true;
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(
      widget.phone,
      otp,
      countryCode: widget.countryCode,
    );
    if (!mounted) return;
    if (ok) {
      _resendTimer?.cancel();
      await context.read<AddressProvider>().fetchAddresses();
      if (!mounted) return;
      context.go('/select-location');
    } else {
      _verifyingOrNavigating = false;
    }
  }

  Future<void> _resend() async {
    if (_resendSecondsLeft > 0) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.requestOtp(
      widget.phone,
      countryCode: widget.countryCode,
    );
    if (!mounted) return;
    if (ok) {
      _otpCtrl.clear();
      _startResendCountdown(auth.resendCooldownSeconds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New OTP sent to ${_formattedPhone()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isError = auth.errorMessage != null &&
        (auth.otpStatus == OtpVerificationStatus.invalid ||
            auth.otpStatus == OtpVerificationStatus.expired);
    final canVerify = _otpCtrl.text.trim().length == 6 && !auth.isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'OTP Verification'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Verify your mobile number',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We have sent a verification code to ${_formattedPhone()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                ),
                onPressed: auth.isLoading ? null : () => context.pop(),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Change mobile number'),
              ),
            ),

            if (auth.developmentOtp != null && auth.developmentOtp!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.developer_mode,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Development OTP: ${auth.developmentOtp!}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: auth.developmentOtp!));
                        _otpCtrl.text = auth.developmentOtp!;
                        setState(() {});
                      },
                      child: const Text('Copy & Fill'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            if (isError)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.onErrorContainer,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              maxLength: 6,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) {
                auth.clearError();
                setState(() {});
              },
              onSubmitted: (_) {
                if (canVerify) _verify();
              },
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 10,
              ),
              decoration: const InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                hintText: '• • • • • •',
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canVerify ? _verify : null,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verify'),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_resendSecondsLeft > 0)
                  Text(
                    'Resend OTP in 00:${_resendSecondsLeft.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  )
                else
                  TextButton(
                    onPressed: auth.isLoading ? null : _resend,
                    child: const Text('Resend OTP'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
