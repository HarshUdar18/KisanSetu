import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController(text: '9876543212');
  final _passCtrl = TextEditingController();
  bool _otpMode = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FarmerAuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(Icons.agriculture,
                    size: 44, color: AppColors.harvestGold),
              ),
              const SizedBox(height: 14),
              Text('Farmer Portal Login',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                'शेतकरी लॉगिन • Role-verified access for Farmers & FPOs',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          labelText: 'Registered Mobile Number',
                          prefixText: '+91 ',
                          counterText: '',
                        ),
                      ),
                      if (!_otpMode) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                      ],
                      if (auth.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(auth.errorMessage!,
                            style: const TextStyle(color: AppColors.error, fontSize: 12)),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  if (_otpMode) {
                                    await auth.requestOtp(_phoneCtrl.text.trim());
                                    if (!context.mounted) return;
                                    context.push('/otp-verify',
                                        extra: {'phone': _phoneCtrl.text.trim()});
                                  } else {
                                    final ok = await auth.login(
                                      _phoneCtrl.text.trim(),
                                      _passCtrl.text,
                                    );
                                    if (ok && context.mounted) {
                                      context.go('/dashboard');
                                    }
                                  }
                                },
                          child: Text(_otpMode
                              ? 'Send Verification OTP'
                              : 'Sign In as Farmer'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => setState(() => _otpMode = !_otpMode),
                          child: Text(_otpMode
                              ? 'Login with Password Instead'
                              : 'Login with Mobile OTP'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New Farmer?'),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('Register & Start KYC'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _villageCtrl = TextEditingController(text: 'Mulshi');
  final _districtCtrl = TextEditingController(text: 'Pune');
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _villageCtrl.dispose();
    _districtCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FarmerAuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Farmer Registration'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          children: [
            Text('Join Kisan Setu Producer Network',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name (as per Aadhaar)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+91 ',
                counterText: '',
              ),
              validator: (v) =>
                  (v == null || v.trim().length != 10) ? '10 digits required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _villageCtrl,
                    decoration: const InputDecoration(labelText: 'Village'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _districtCtrl,
                    decoration: const InputDecoration(labelText: 'District'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Create Password'),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      await auth.registerFarmer(
                        fullName: _nameCtrl.text.trim(),
                        phone: _phoneCtrl.text.trim(),
                        password: _passCtrl.text,
                        village: _villageCtrl.text.trim(),
                        district: _districtCtrl.text.trim(),
                        stateName: 'Maharashtra',
                      );
                      if (!context.mounted) return;
                      context.push('/otp-verify', extra: {
                        'phone': _phoneCtrl.text.trim(),
                        'fromRegistration': true,
                      });
                    },
              child: const Text('Register & Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

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

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FarmerAuthProvider>();
    final isInvalid = auth.otpStatus == FarmerOtpStatus.invalid;
    final isExpired = auth.otpStatus == FarmerOtpStatus.expired;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'OTP Verification'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verify +91 ${widget.phone}',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            const Text('Enter the 6-digit verification code sent via SMS.'),
            if (auth.developmentOtp != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.md),
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
            const SizedBox(height: 16),
            if (isInvalid || isExpired)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  auth.errorMessage ?? 'Invalid or expired OTP',
                  style: const TextStyle(color: AppColors.onErrorContainer),
                ),
              ),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 8),
              decoration: const InputDecoration(counterText: '', hintText: '••••••'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isExpired
                    ? null
                    : () async {
                        final ok = await auth.verifyOtp(
                            widget.phone, _otpCtrl.text.trim());
                        if (ok && context.mounted) {
                          context.go(widget.fromRegistration ? '/kyc' : '/dashboard');
                        }
                      },
                child: const Text('Verify & Continue'),
              ),
            ),
            TextButton(
              onPressed: () => auth.requestOtp(widget.phone),
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0;
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _devCode;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Enter your registered phone number or email.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await context.read<DioClient>().post('/auth/forgot-password', data: {'identifier': phone});
      final data = res.data['data'] as Map<String, dynamic>?;
      if (mounted) {
        setState(() {
          _step = 1;
          _loading = false;
          _devCode = (kDebugMode && data != null)
              ? data['developmentResetCode']?.toString()
              : null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Unable to initiate password reset. Check connection.';
        });
      }
    }
  }

  Future<void> _submitReset() async {
    if (_otpCtrl.text.trim().length < 6 || _passCtrl.text.length < 6) {
      setState(() => _error = 'Enter 6-digit code and password (min 6 chars).');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<DioClient>().post('/auth/reset-password', data: {
        'identifier': _phoneCtrl.text.trim(),
        'token': _otpCtrl.text.trim(),
        'newPassword': _passCtrl.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated! Please sign in.')),
      );
      context.pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Invalid or expired reset code.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Reset Farmer Password'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 10),
            ],
            if (_step == 0)
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Registered Mobile Number or Email'),
              ),
            if (_step == 1) ...[
              if (_devCode != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('Dev Reset Code: $_devCode',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(labelText: '6-Digit Reset Code', counterText: ''),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password (min 6 chars)'),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : (_step == 0 ? _requestReset : _submitReset),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_step == 0 ? 'Send Reset Code' : 'Reset Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
