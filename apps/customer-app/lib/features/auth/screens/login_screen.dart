import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// Implements Stitch `login_screen` with OTP and Password login modes.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController(text: '9876543211');
  final _passCtrl = TextEditingController();
  bool _passwordMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number.')),
      );
      return;
    }
    final ok = await context.read<AuthProvider>().requestOtp(phone);
    if (ok && mounted) {
      context.push('/otp-verify', extra: {'phone': phone});
    }
  }

  Future<void> _submitPassword() async {
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text;
    if (phone.length != 10 || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter 10-digit mobile number and password.')),
      );
      return;
    }
    final ok = await context.read<AuthProvider>().loginWithPassword(phone, pass);
    if (ok && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isPhoneValid = _phoneCtrl.text.trim().length == 10;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.level2,
                    ),
                    child: const Icon(Icons.agriculture_rounded,
                        size: 42, color: AppColors.primary),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.tertiaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco,
                          size: 16, color: AppColors.onTertiaryFixed),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Welcome Back', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text(
                'Enter your registered mobile number to access your fresh farm baskets and orders.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 15, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Direct Farm Connect • 100% Traceable',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.level1,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mobile Number',
                            style: Theme.of(context).textTheme.labelLarge),
                        const Row(
                          children: [
                            Icon(Icons.shield_outlined,
                                size: 13, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Safe & Encrypted',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'Enter 10-digit mobile number',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('+91',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 15)),
                              SizedBox(width: 8),
                              SizedBox(
                                height: 22,
                                child: VerticalDivider(color: AppColors.outlineVariant),
                              ),
                            ],
                          ),
                        ),
                        suffixIcon: isPhoneValid
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
                            : null,
                      ),
                    ),
                    if (_passwordMode) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.sms_outlined, size: 15, color: AppColors.outline),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'An OTP will be sent via SMS for instant verification (Dev OTP: 123456)',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          auth.errorMessage!,
                          style: const TextStyle(
                              color: AppColors.onErrorContainer, fontSize: 12),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: auth.isLoading
                            ? null
                            : (_passwordMode ? _submitPassword : _submitOtp),
                        icon: auth.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.arrow_forward),
                        label: Text(_passwordMode
                            ? 'Sign In with Password'
                            : 'Send Verification Code (OTP)'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'OR',
                            style: TextStyle(fontSize: 11, color: AppColors.outline),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _passwordMode = !_passwordMode),
                        icon: Icon(_passwordMode ? Icons.sms_outlined : Icons.lock_open),
                        label: Text(_passwordMode
                            ? 'Sign in with OTP Instead'
                            : 'Sign in with Password'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.secondaryContainer,
                      child: Icon(Icons.agriculture,
                          color: AppColors.onSecondaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Supporting 12,000+ Farm Cooperatives',
                              style: Theme.of(context).textTheme.labelMedium),
                          Text(
                            'Every basket empowers local farmers directly with 0% intermediary cuts.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New to Kisan Setu?'),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('Create an Account'),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().continueAsGuest();
                  context.go('/home');
                },
                child: const Text('Continue as Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
