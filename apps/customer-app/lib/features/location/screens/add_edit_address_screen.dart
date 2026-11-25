import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../models/address_model.dart';
import '../providers/address_provider.dart';

/// Implements Stitch `add_edit_address`.
class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? existingAddress;

  const AddEditAddressScreen({super.key, this.existingAddress});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _line1Ctrl;
  late final TextEditingController _line2Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _pinCtrl;
  String _label = 'HOME';
  bool _isDefault = true;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAddress;
    _nameCtrl = TextEditingController(text: 'Sunita Deshmukh');
    _phoneCtrl = TextEditingController(text: '9876543211');
    _line1Ctrl = TextEditingController(text: a?.addressLine1 ?? '');
    _line2Ctrl = TextEditingController(text: a?.addressLine2 ?? '');
    _cityCtrl = TextEditingController(text: a?.city ?? 'Pune');
    _pinCtrl = TextEditingController(text: a?.pincode ?? '411038');
    _label = a?.label ?? 'HOME';
    _isDefault = a?.isDefault ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AddressProvider>();
    final check = await provider.checkServiceability(_pinCtrl.text.trim());
    if (!mounted) return;

    final addr = AddressModel(
      id: widget.existingAddress?.id ?? '',
      label: _label,
      addressLine1: _line1Ctrl.text.trim(),
      addressLine2: _line2Ctrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: 'Maharashtra',
      pincode: _pinCtrl.text.trim(),
      isDefault: _isDefault,
    );

    await provider.addAddress(addr);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(check.isServiceable
            ? 'Address saved! Serviceable via ${check.serviceAreaName}.'
            : 'Address saved (outside current pilot delivery zone).'),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: KisanStackAppBar(
        title: widget.existingAddress == null ? 'Add New Address' : 'Edit Address',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          children: [
            Text('Recipient Information', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              validator: (v) => (v == null || v.trim().length < 10) ? 'Enter 10 digits' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Address Details', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            TextFormField(
              controller: _line1Ctrl,
              decoration: const InputDecoration(
                  labelText: 'House / Flat / Building No.'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _line2Ctrl,
              decoration: const InputDecoration(labelText: 'Street / Locality / Landmark'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityCtrl,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _pinCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'PIN Code',
                      counterText: '',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().length != 6) ? '6-digit PIN' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Address Type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: ['HOME', 'WORK', 'OTHER'].map((type) {
                final selected = _label == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (_) => setState(() => _label = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Set as default delivery address'),
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Verify Serviceability & Save Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
