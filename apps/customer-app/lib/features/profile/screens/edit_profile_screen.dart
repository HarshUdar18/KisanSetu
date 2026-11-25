import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../auth/providers/auth_provider.dart';

/// Implements Stitch `edit_profile` (Personal Info, Mobile, Email).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl = TextEditingController(text: auth.fullName ?? 'Sunita Deshmukh');
    _emailCtrl = TextEditingController(
        text: auth.email ?? 'sunita.deshmukh@kisansetu.local');
    _phoneCtrl = TextEditingController(text: auth.identifier ?? '9876543211');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Edit Profile'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              prefixText: '+91 ',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email Address'),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      await auth.updateProfile(
                        fullName: _nameCtrl.text.trim(),
                        email: _emailCtrl.text.trim(),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully')),
                      );
                      context.pop();
                    },
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
