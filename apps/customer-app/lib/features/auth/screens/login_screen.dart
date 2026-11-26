import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// Fast, Zepto-inspired Mobile Number entry screen using the Kisan Setu design system.
/// Flow: Splash Screen -> Phone Number Screen -> OTP Verification -> Location Selection -> Dashboard.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  String _countryCode = '+91';
  String? _validationError;

  static const List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'label': 'India (+91)'},
    {'code': '+971', 'label': 'UAE (+971)'},
    {'code': '+44', 'label': 'UK (+44)'},
    {'code': '+1', 'label': 'US (+1)'},
  ];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final err = AuthProvider.validatePhoneNumber(
      _phoneCtrl.text,
      countryCode: _countryCode,
    );
    if (err != null) {
      setState(() => _validationError = err);
      return;
    }

    setState(() => _validationError = null);
    final auth = context.read<AuthProvider>();
    final ok = await auth.requestOtp(
      _phoneCtrl.text,
      countryCode: _countryCode,
    );
    if (!mounted) return;
    if (ok) {
      context.push(
        '/otp-verify',
        extra: {
          'phone':
              auth.otpChallengePhone ??
              AuthProvider.normalizePhoneNumber(
                _phoneCtrl.text,
                countryCode: _countryCode,
              ),
          'countryCode': _countryCode,
          'cooldown': auth.resendCooldownSeconds,
        },
      );
    }
  }

  Future<void> _skipAsGuest() async {
    final auth = context.read<AuthProvider>();
    final settings = context.read<AppSettingsProvider>();
    auth.continueAsGuest();
    if (!settings.isLocationSelected) {
      await settings.skipLocation();
    }
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isIndia = _countryCode == '+91';
    final isCurrentlyValid =
        AuthProvider.validatePhoneNumber(
          _phoneCtrl.text,
          countryCode: _countryCode,
        ) ==
        null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - AppSpacing.md * 2)
                    .clamp(0.0, double.infinity),
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Top bar: Brand mark + Skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: AppColors.harvestGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Image.asset(
                            AppAssets.wordmark,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: auth.isLoading ? null : _skipAsGuest,
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Image.asset(
                  AppAssets.farmToMarketBadge,
                  height: 112,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Welcome to Kisan Setu',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter your mobile number to continue',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Country code + phone input card
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _countryCode,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        items: _countryCodes
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c['code'],
                                child: Text(c['code']!),
                              ),
                            )
                            .toList(),
                        onChanged: auth.isLoading
                            ? null
                            : (val) {
                                if (val != null) {
                                  setState(() {
                                    _countryCode = val;
                                    _validationError = null;
                                  });
                                }
                              },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      maxLength: isIndia ? 10 : 15,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) {
                        if (_validationError != null ||
                            auth.errorMessage != null) {
                          setState(() => _validationError = null);
                          auth.clearError();
                        } else {
                          setState(() {});
                        }
                      },
                      onSubmitted: (_) => _submit(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        hintText: isIndia
                            ? '10-digit mobile number'
                            : 'Mobile number',
                        suffixIcon: isCurrentlyValid
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),

              if (_validationError != null || auth.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationError ?? auth.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.onErrorContainer,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue'),
                ),
              ),

              const Spacer(),
              Center(
                child: Text(
                  'By continuing, you will verify your number with a one-time SMS code.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
            ),
          ),
        ),
      ),
    );
  }
}
