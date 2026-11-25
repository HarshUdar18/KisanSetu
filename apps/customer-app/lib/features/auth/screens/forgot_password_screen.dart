import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `forgot_password_verification` + Reset & Create New Password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0; // 0: phone, 1: otp, 2: new password
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Reset Password'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _step == 0
                  ? 'Forgot Your Password?'
                  : _step == 1
                      ? 'Verify Reset Code'
                      : 'Create New Password',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              _step == 0
                  ? 'Enter your registered mobile number to receive a password reset OTP.'
                  : _step == 1
                      ? 'Enter the 6-digit code sent to +91 ${_phoneCtrl.text}.'
                      : 'Choose a strong password of at least 6 characters.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_step == 0)
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixText: '+91 ',
                  counterText: '',
                ),
              ),
            if (_step == 1)
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: '6-Digit Reset OTP (Dev: 123456)',
                  counterText: '',
                ),
              ),
            if (_step == 2) ...[
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_step == 0) {
                    if (_phoneCtrl.text.trim().length != 10) return;
                    setState(() => _step = 1);
                  } else if (_step == 1) {
                    if (_otpCtrl.text.trim().length != 6) return;
                    setState(() => _step = 2);
                  } else {
                    if (_passCtrl.text.length < 6 ||
                        _passCtrl.text != _confirmCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords must match (min 6 chars).')),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset successful!')),
                    );
                    context.go('/login');
                  }
                },
                child: Text(_step == 2 ? 'Save New Password' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
