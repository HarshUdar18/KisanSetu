import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/location/location_models.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/address_model.dart';
import '../providers/address_provider.dart';

/// Redesigned Add / Edit Address screen inspired by the BigBasket layout
/// using the Kisan Setu green-and-white design system.
class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? existingAddress;
  final Map<String, dynamic>? initialLocation;

  const AddEditAddressScreen({
    super.key,
    this.existingAddress,
    this.initialLocation,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _flatCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _landmarkCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;

  String _recipientType = 'MYSELF'; // MYSELF | SOMEONE_ELSE
  String _label = 'Home'; // Home | Office | Others
  bool _isDefault = true;
  bool _isSubmitting = false;

  late String _locationName;
  late String _locality;
  late String _city;
  late String _district;
  late String _stateName;
  late String _pincode;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAddress;
    final auth = context.read<AuthProvider>();
    final settings = context.read<AppSettingsProvider>();

    _recipientType = a?.recipientType ?? 'MYSELF';
    _label = _normalizeLabel(a?.label);
    _isDefault = a?.isDefault ?? true;

    _flatCtrl = TextEditingController(text: a?.addressLine1 ?? '');
    _streetCtrl = TextEditingController(
      text: a?.streetBuilding ?? a?.addressLine2 ?? '',
    );
    _landmarkCtrl = TextEditingController(text: a?.landmark ?? '');

    if (_recipientType == 'MYSELF') {
      _firstNameCtrl = TextEditingController(
        text: (a?.recipientFirstName?.isNotEmpty == true)
            ? a!.recipientFirstName!
            : auth.firstName,
      );
      _lastNameCtrl = TextEditingController(
        text: (a?.recipientLastName?.isNotEmpty == true)
            ? a!.recipientLastName!
            : auth.lastName,
      );
      _phoneCtrl = TextEditingController(
        text: (a?.recipientPhone?.isNotEmpty == true)
            ? a!.recipientPhone!
            : _stripCountryCode(auth.identifier ?? ''),
      );
    } else {
      _firstNameCtrl =
          TextEditingController(text: a?.recipientFirstName ?? '');
      _lastNameCtrl = TextEditingController(text: a?.recipientLastName ?? '');
      _phoneCtrl = TextEditingController(text: a?.recipientPhone ?? '');
    }

    final initGeo = widget.initialLocation?['geocode'];
    final initPin = (widget.initialLocation?['pincode'] as String?)?.trim() ?? '';
    final initShort =
        (widget.initialLocation?['shortName'] as String?)?.trim() ?? '';

    if (initGeo is GeocodeResultModel) {
      _locationName = initGeo.displayName;
      _locality = (initGeo.village ?? initShort).trim();
      _city = (initGeo.district ?? initGeo.village ?? 'Pune').trim();
      _district = (initGeo.district ?? _city).trim();
      _stateName = (initGeo.state ?? 'Maharashtra').trim();
      _pincode = initPin.isNotEmpty
          ? initPin
          : (a?.pincode ?? settings.selectedLocationPin);
      _latitude = initGeo.latitude;
      _longitude = initGeo.longitude;
    } else {
      _locationName = a?.locationSummary ??
          settings.selectedFullAddress ??
          settings.selectedLocationName;
      _locality = settings.selectedLocationName;
      _city = a?.city ?? 'Pune';
      _district = a?.city ?? 'Pune';
      _stateName = a?.state ?? 'Maharashtra';
      _pincode = a?.pincode ?? settings.selectedLocationPin;
      _latitude = a?.latitude ?? settings.selectedLatitude;
      _longitude = a?.longitude ?? settings.selectedLongitude;
    }

    for (final ctrl in [
      _flatCtrl,
      _firstNameCtrl,
      _lastNameCtrl,
      _phoneCtrl,
    ]) {
      ctrl.addListener(_onFormChanged);
    }
  }

  String _normalizeLabel(String? raw) {
    final upper = (raw ?? 'Home').trim().toUpperCase();
    if (upper == 'OFFICE' || upper == 'WORK') return 'Office';
    if (upper == 'OTHERS' || upper == 'OTHER') return 'Others';
    return 'Home';
  }

  String _stripCountryCode(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10 && digits.startsWith('91')) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _flatCtrl.dispose();
    _streetCtrl.dispose();
    _landmarkCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onRecipientTypeChanged(String type) {
    if (_recipientType == type) return;
    final auth = context.read<AuthProvider>();
    setState(() {
      _recipientType = type;
      if (type == 'MYSELF') {
        if (_firstNameCtrl.text.trim().isEmpty) {
          _firstNameCtrl.text = auth.firstName;
        }
        if (_lastNameCtrl.text.trim().isEmpty) {
          _lastNameCtrl.text = auth.lastName;
        }
        if (_phoneCtrl.text.trim().isEmpty) {
          _phoneCtrl.text = _stripCountryCode(auth.identifier ?? '');
        }
      } else {
        _firstNameCtrl.clear();
        _lastNameCtrl.clear();
        _phoneCtrl.clear();
      }
    });
  }

  bool get _isFormReady {
    final flatOk = _flatCtrl.text.trim().isNotEmpty;
    final firstOk = _firstNameCtrl.text.trim().isNotEmpty;
    final lastOk = _lastNameCtrl.text.trim().isNotEmpty;
    final phoneDigits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    final phoneOk = phoneDigits.length >= 10 && phoneDigits.length <= 15;
    final pinOk = RegExp(r'^[1-9]\d{5}$').hasMatch(_pincode.trim());
    return flatOk && firstOk && lastOk && phoneOk && pinOk;
  }

  Future<void> _changeLocation() async {
    final result = await context.push<dynamic>(
      '/map-location',
      extra: {'returnSelectionOnly': true},
    );
    if (!mounted || result == null) return;

    if (result is Map<String, dynamic>) {
      final geo = result['geocode'];
      final pin = (result['pincode'] as String?)?.trim() ?? '';
      final shortName = (result['shortName'] as String?)?.trim() ?? '';
      if (geo is GeocodeResultModel) {
        setState(() {
          _locationName = geo.displayName;
          _locality = (geo.village ?? shortName).trim();
          _city = (geo.district ?? geo.village ?? 'Pune').trim();
          _district = (geo.district ?? _city).trim();
          _stateName = (geo.state ?? 'Maharashtra').trim();
          if (pin.isNotEmpty) _pincode = pin;
          _latitude = geo.latitude;
          _longitude = geo.longitude;
        });
      }
    }
  }

  Future<void> _confirmAddress() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (!RegExp(r'^[1-9]\d{5}$').hasMatch(_pincode.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery location with a valid PIN code.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final addressProvider = context.read<AddressProvider>();
    final auth = context.read<AuthProvider>();
    final settings = context.read<AppSettingsProvider>();

    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final street = _streetCtrl.text.trim();
    final landmark = _landmarkCtrl.text.trim();

    final summary = _locationName.trim().isNotEmpty
        ? _locationName.trim()
        : [_locality, _city, _stateName]
            .where((s) => s.trim().isNotEmpty)
            .join(', ');

    final addressModel = AddressModel(
      id: widget.existingAddress?.id ?? '',
      label: _label,
      addressLine1: _flatCtrl.text.trim(),
      addressLine2: street.isNotEmpty ? street : (_locality.isNotEmpty ? _locality : null),
      city: _city.isNotEmpty ? _city : 'Pune',
      state: _stateName.isNotEmpty ? _stateName : 'Maharashtra',
      pincode: _pincode.trim(),
      latitude: _latitude,
      longitude: _longitude,
      isDefault: _isDefault,
      recipientType: _recipientType,
      recipientFirstName: firstName,
      recipientLastName: lastName,
      recipientPhone: phone,
      streetBuilding: street.isNotEmpty ? street : null,
      landmark: landmark.isNotEmpty ? landmark : null,
      locationSummary: summary.isNotEmpty ? summary : null,
    );

    final check = await addressProvider.checkServiceability(_pincode.trim());
    final saved = widget.existingAddress != null &&
            widget.existingAddress!.id.isNotEmpty
        ? await addressProvider.updateAddress(addressModel)
        : await addressProvider.addAddress(addressModel);

    if (!mounted) return;
    if (!saved) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            addressProvider.errorMessage ?? 'Unable to save address. Please retry.',
          ),
        ),
      );
      return;
    }

    await addressProvider.fetchAddresses();
    if (!mounted) return;

    if (addressProvider.defaultAddress != null) {
      await settings.syncFromDefaultAddress(addressProvider.defaultAddress);
    }

    // Update customer profile name ONLY when ordering for Myself
    if (_recipientType == 'MYSELF' && firstName.isNotEmpty) {
      final fullName = '$firstName $lastName'.trim();
      await auth.updateProfile(
        fullName: fullName,
        pincode: _pincode.trim(),
        defaultAddress: addressModel.fullAddress,
      );
      await auth.refreshProfile();
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          check.isServiceable
              ? 'Address confirmed! Delivery available in ${check.serviceAreaName ?? _city}.'
              : 'Address saved. Delivery availability will be verified at checkout.',
        ),
      ),
    );
    context.pop(addressModel);
  }

  @override
  Widget build(BuildContext context) {
    final locationTitle = _locality.isNotEmpty
        ? _locality
        : (_locationName.isNotEmpty
            ? _locationName.split(',').first.trim()
            : 'Delivery Location');
    final locationSubtitle = [
      if (_locationName.isNotEmpty) _locationName,
      if (_city.isNotEmpty && !_locationName.contains(_city)) _city,
      if (_district.isNotEmpty &&
          _district != _city &&
          !_locationName.contains(_district))
        _district,
      if (_pincode.isNotEmpty && !_locationName.contains(_pincode))
        'PIN: $_pincode',
    ].join(', ');

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Dark-green header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 14),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'SELECT DELIVERY LOCATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // White rounded container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                          children: [
                            Text(
                              'Add your address details',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 16),

                            // A. Who are you ordering for?
                            Text(
                              'Who are you ordering for?',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _RecipientRadio(
                                  label: 'Myself',
                                  selected: _recipientType == 'MYSELF',
                                  onTap: () => _onRecipientTypeChanged('MYSELF'),
                                ),
                                const SizedBox(width: 20),
                                _RecipientRadio(
                                  label: 'Someone else',
                                  selected: _recipientType == 'SOMEONE_ELSE',
                                  onTap: () =>
                                      _onRecipientTypeChanged('SOMEONE_ELSE'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // B. Save address as
                            Text(
                              'Save address as',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _AddressTypeChip(
                                    icon: Icons.home_outlined,
                                    label: 'Home',
                                    selected: _label == 'Home',
                                    onTap: () => setState(() => _label = 'Home'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _AddressTypeChip(
                                    icon: Icons.business_outlined,
                                    label: 'Office',
                                    selected: _label == 'Office',
                                    onTap: () =>
                                        setState(() => _label = 'Office'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _AddressTypeChip(
                                    icon: Icons.location_on_outlined,
                                    label: 'Others',
                                    selected: _label == 'Others',
                                    onTap: () =>
                                        setState(() => _label = 'Others'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // C. Highlighted Location Card with Change button
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          locationTitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          locationSubtitle.isNotEmpty
                                              ? locationSubtitle
                                              : 'Tap Change to pick your delivery location',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _changeLocation,
                                    child: const Text(
                                      'Change',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // D. Address input fields
                            TextFormField(
                              controller: _flatCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Flat / House number *',
                                hintText: 'e.g. Flat 402, B-Wing',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Flat / House number is required'
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _streetCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Street / Building name (Optional)',
                                hintText: 'e.g. Green Meadows Society, Main Road',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _landmarkCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Landmark (Optional)',
                                hintText: 'e.g. Near City Hospital',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // E. Contact details
                            Text(
                              'Contact details',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstNameCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'First name *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Required'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lastNameCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'Last name *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Required'
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              maxLength: 15,
                              decoration: const InputDecoration(
                                labelText: 'Mobile number *',
                                hintText: '10-digit mobile number',
                                counterText: '',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final digits =
                                    (v ?? '').replaceAll(RegExp(r'\D'), '');
                                if (digits.length < 10 || digits.length > 15) {
                                  return 'Enter a valid 10-digit mobile number';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      // Confirm address button
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: (_isFormReady && !_isSubmitting)
                                  ? _confirmAddress
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.outlineVariant,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Confirm address',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipientRadio extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RecipientRadio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.outline,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AddressTypeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
