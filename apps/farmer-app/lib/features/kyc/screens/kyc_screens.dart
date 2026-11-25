import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';
import '../../auth/providers/auth_provider.dart';

/// Implements Stitch `farmer_kyc_digital_identity` (Step 1 of 4).
class KycIdentityScreen extends StatefulWidget {
  const KycIdentityScreen({super.key});

  @override
  State<KycIdentityScreen> createState() => _KycIdentityScreenState();
}

class _KycIdentityScreenState extends State<KycIdentityScreen> {
  String _classification = 'Individual Smallholder / Landowner';
  final _aadhaarCtrl = TextEditingController(text: '8842');
  final _panCtrl = TextEditingController(text: 'ABCPS1234F');
  final _kccCtrl = TextEditingController(text: 'MH-PUN-KCC-99214');

  @override
  void dispose() {
    _aadhaarCtrl.dispose();
    _panCtrl.dispose();
    _kccCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Farmer KYC (Step 1 of 4)'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          const LinearProgressIndicator(value: 0.25, color: AppColors.primary),
          const SizedBox(height: 12),
          Text('Verify Your Farmer Identity',
              style: Theme.of(context).textTheme.headlineMedium),
          const Text('शेतकरी ओळख पडताळणी • Official Digital Profile Setup'),
          const SizedBox(height: 12),
          ...[
            'Individual Smallholder / Landowner',
            'Tenant / Sharecropper Farmer',
            'FPO / Farmer Producer Company Member',
          ].map((c) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(c),
                  leading: Icon(
                    _classification == c
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: _classification == c
                        ? AppColors.primary
                        : AppColors.outline,
                  ),
                  onTap: () => setState(() => _classification = c),
                ),
              )),
          const SizedBox(height: 12),
          TextField(
            controller: _aadhaarCtrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: 'Aadhaar Last 4 Digits (Masked for Privacy)',
              prefixText: '•••• •••• ',
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _panCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'PAN Number'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _kccCtrl,
            decoration:
                const InputDecoration(labelText: 'Kisan Credit Card (Optional)'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push('/kyc/land-records', extra: {
              'aadhaarLast4': _aadhaarCtrl.text.trim(),
              'pan': _panCtrl.text.trim(),
            }),
            child: const Text('Continue to Land Records (7/12) ->'),
          ),
        ],
      ),
    );
  }
}

/// Implements Stitch `land_record_verification_7_12` (Step 2 of 4).
class LandRecordScreen extends StatefulWidget {
  final Map<String, dynamic> kycData;

  const LandRecordScreen({super.key, this.kycData = const {}});

  @override
  State<LandRecordScreen> createState() => _LandRecordScreenState();
}

class _LandRecordScreenState extends State<LandRecordScreen> {
  final _gatCtrl = TextEditingController(text: 'Gat No. 142, Mulshi');
  final _areaCtrl = TextEditingController(text: '3.4 Acres');
  bool _docAttached = false;

  @override
  void dispose() {
    _gatCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Land Record (7/12 & 8A)'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          const LinearProgressIndicator(value: 0.50, color: AppColors.primary),
          const SizedBox(height: 12),
          Text('Land Record Verification',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _gatCtrl,
            decoration: const InputDecoration(labelText: 'Survey / Gat Number'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _areaCtrl,
            decoration: const InputDecoration(labelText: 'Total Cultivable Area'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => setState(() => _docAttached = true),
            icon: Icon(_docAttached ? Icons.check_circle : Icons.upload_file),
            label: Text(_docAttached
                ? '7/12 Extract Attached (Encrypted Upload)'
                : 'Upload 7/12 & 8A Extract'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/kyc/bank-dbt', extra: widget.kycData),
            child: const Text('Continue to Bank Account & DBT ->'),
          ),
        ],
      ),
    );
  }
}

/// Implements Stitch `bank_account_dbt_setup` (Step 3 of 4).
class BankDbtScreen extends StatefulWidget {
  final Map<String, dynamic> kycData;

  const BankDbtScreen({super.key, this.kycData = const {}});

  @override
  State<BankDbtScreen> createState() => _BankDbtScreenState();
}

class _BankDbtScreenState extends State<BankDbtScreen> {
  final _holderCtrl = TextEditingController(text: 'Ramesh Balasaheb Shinde');
  final _bankCtrl = TextEditingController(text: 'State Bank of India');
  final _accCtrl = TextEditingController(text: '309812344201');
  final _ifscCtrl = TextEditingController(text: 'SBIN0001245');

  @override
  void dispose() {
    _holderCtrl.dispose();
    _bankCtrl.dispose();
    _accCtrl.dispose();
    _ifscCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Bank Account & Escrow DBT'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          const LinearProgressIndicator(value: 0.75, color: AppColors.primary),
          const SizedBox(height: 12),
          Text('Bank Account & Mandate Setup',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _holderCtrl,
            decoration: const InputDecoration(labelText: 'Account Holder Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bankCtrl,
            decoration: const InputDecoration(labelText: 'Bank Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _accCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Bank Account Number'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ifscCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'IFSC Code'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<FarmerAuthProvider>().submitKyc(
                    aadhaarLast4:
                        widget.kycData['aadhaarLast4'] as String? ?? '8842',
                    pan: widget.kycData['pan'] as String? ?? 'ABCPS1234F',
                    bankName: _bankCtrl.text.trim(),
                    accountNumber: _accCtrl.text.trim(),
                    ifsc: _ifscCtrl.text.trim(),
                  );
              context.push('/kyc/certificate');
            },
            child: const Text('Submit KYC for Verification'),
          ),
        ],
      ),
    );
  }
}

/// Implements Stitch `kyc_verification_smart_certificate` + all KYC status views.
class KycCertificateScreen extends StatelessWidget {
  const KycCertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FarmerAuthProvider>();
    final status = auth.kycStatus;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'KYC Status & Smart Certificate'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == KycStatus.approved
                        ? AppColors.secondaryContainer
                        : AppColors.tertiaryFixed,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'KYC STATUS: ${status.name.toUpperCase()}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryFixed),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  auth.fullName ?? 'Ramesh Balasaheb Shinde',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aadhaar: ${auth.aadhaarMasked} • PAN: ${auth.panMasked}',
                  style: const TextStyle(
                      color: AppColors.onPrimaryContainer, fontSize: 12),
                ),
                Text(
                  'DBT Bank: ${auth.bankName} (${auth.bankAccountMasked}) • ${auth.ifsc}',
                  style: const TextStyle(
                      color: AppColors.onPrimaryContainer, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Farmer Dashboard'),
            ),
          ),
        ],
      ),
    );
  }
}
