import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `select_location_manually`.
class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectAndCheck(String name, String pinCode, {String? area}) async {
    final settings = context.read<AppSettingsProvider>();
    await settings.setDeliveryLocation(name, pinCode, area: area);
    if (!mounted) return;
    context.push('/serviceability-check', extra: {'pinCode': pinCode, 'name': name});
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final recent = settings.recentLocations.where((l) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return (l['name'] ?? '').toLowerCase().contains(q) ||
          (l['pinCode'] ?? '').contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Select Delivery Location'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: InputDecoration(
              hintText: 'Enter 6-digit PIN code or area (e.g. 411038)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.length == 6
                  ? TextButton(
                      onPressed: () => _selectAndCheck('PIN $_query', _query),
                      child: const Text('Check'),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/map-picker'),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Pick on Map'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/addresses'),
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Saved Addresses'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Recent Locations', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          ...recent.map((loc) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceContainer,
                    child: Icon(Icons.history, color: AppColors.primary),
                  ),
                  title: Text('${loc['name']} (${loc['pinCode']})'),
                  subtitle: Text(loc['area'] ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectAndCheck(loc['name']!, loc['pinCode']!, area: loc['area']),
                ),
              )),
          const SizedBox(height: AppSpacing.md),
          Text('Active Pune Pilot Corridors', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          ...AppConstants.pilotLocations.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.secondaryContainer,
                    child: Icon(Icons.verified, color: AppColors.onSecondaryContainer),
                  ),
                  title: Text('${p['name']} • ${p['pinCode']}'),
                  subtitle: Text('${p['hub']} • 12-hr Morning Delivery'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectAndCheck(p['name'] as String, p['pinCode'] as String),
                ),
              )),
        ],
      ),
    );
  }
}
