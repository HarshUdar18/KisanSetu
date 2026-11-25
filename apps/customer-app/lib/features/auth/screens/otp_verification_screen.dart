import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/auth_provider.dart';

/// Implements Stitch:
/// - `otp_verification`
/// - `otp_incorrect_retry`
/// - `otp_expired_resend_options`
class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final bool fromRegistration;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.fromRegistration = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpCtrl = TextEditingController();
  int _secondsLeft = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        context.read<AuthProvider>().simulateOtpExpired();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final ok = await context
        .read<AuthProvider>()
        .verifyOtp(widget.phone, _otpCtrl.text.trim());
    if (!mounted) return;
    if (ok) {
      _timer?.cancel();
      if (widget.fromRegistration) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful! Welcome to Kisan Setu.'),
          ),
        );
      }
      context.go('/home');
    }
  }

  Future<void> _resend(String channel) async {
    await context.read<AuthProvider>().requestOtp(widget.phone);
    if (!mounted) return;
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('New OTP sent via $channel to +91 ${widget.phone}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isIncorrect = auth.otpStatus == OtpVerificationStatus.invalid;
    final isExpired = auth.otpStatus == OtpVerificationStatus.expired;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Verify Mobile Number'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              isExpired
                  ? 'Verification Code Expired'
                  : isIncorrect
                      ? 'Incorrect Code Entered'
                      : 'Enter 6-Digit Verification Code',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Sent to +91 ${widget.phone}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            if (auth.developmentOtp != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.developer_mode, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Development OTP',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                          Text(
                            auth.developmentOtp!,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 4),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _otpCtrl.text = auth.developmentOtp!;
                      },
                      child: const Text('Autofill'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (isIncorrect || isExpired)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        auth.errorMessage ??
                            (isExpired
                                ? 'OTP expired. Choose a channel below to resend.'
                                : 'Invalid OTP. Please check and retry.'),
                        style: const TextStyle(
                            color: AppColors.onErrorContainer, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 8,
              ),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '• • • • • •',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading || isExpired ? null : _verify,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Verify & Continue'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!isExpired)
              Center(
                child: Text(
                  'Code expires in 00:${_secondsLeft.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Choose How to Receive New Code',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _resend('SMS'),
                  icon: const Icon(Icons.sms_outlined, size: 18),
                  label: const Text('Resend SMS'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _resend('WhatsApp'),
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('WhatsApp OTP'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _resend('Voice Call'),
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: const Text('Voice Call'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
