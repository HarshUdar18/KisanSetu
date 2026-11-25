import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/farmer_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/farmer_header.dart';
import '../../auth/providers/auth_provider.dart';

/// Implements Stitch `farmer_profile_farmstead_overview`.
class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FarmerAuthProvider>();
    final settings = context.watch<FarmerSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerTabHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 34, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.fullName ?? 'Ramesh Balasaheb Shinde',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${settings.farmName} • ${settings.landArea} ${settings.landUnit}',
                        style: const TextStyle(
                            color: AppColors.onPrimaryContainer, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/edit-profile'),
                  icon: const Icon(Icons.edit, color: AppColors.tertiaryFixed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.verified_user, color: AppColors.primary),
                  title: const Text('Farmer KYC & Smart Certificate'),
                  subtitle: Text('Status: ${auth.kycStatus.name.toUpperCase()}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/kyc/certificate'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.landscape, color: AppColors.primary),
                  title: const Text('Farm Plots & Soil Health'),
                  subtitle: Text('${settings.soilType} • ${settings.waterSource}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/farm-plots'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.groups, color: AppColors.primary),
                  title: const Text('FPO Affiliation & Collection Hub'),
                  subtitle: Text(settings.selectedHubName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/fpo-affiliation'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                  title: const Text('Farmer Settings & Language'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.support_agent, color: AppColors.primary),
                  title: const Text('Farmer Helpdesk & Taluka CSC'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/support'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            onPressed: () async {
              final ok = await ConfirmationDialog.show(
                context,
                title: 'Logout from Farmer Portal?',
                message: 'Your active produce lots and settlements remain safely stored.',
                confirmLabel: 'Logout',
                isDestructive: true,
              );
              if (ok == true && context.mounted) {
                await auth.logout();
                if (!context.mounted) return;
                context.go('/welcome');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _farmCtrl;
  late final TextEditingController _areaCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<FarmerSettingsProvider>();
    _farmCtrl = TextEditingController(text: s.farmName);
    _areaCtrl = TextEditingController(text: s.landArea);
  }

  @override
  void dispose() {
    _farmCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Edit Farm & Profile'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          TextField(
            controller: _farmCtrl,
            decoration: const InputDecoration(labelText: 'Farmstead Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _areaCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Land Area (Acres)'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<FarmerSettingsProvider>().updateFarmDetails(
                    farmName: _farmCtrl.text.trim(),
                    landArea: _areaCtrl.text.trim(),
                  );
              context.pop();
            },
            child: const Text('Save Farm Details'),
          ),
        ],
      ),
    );
  }
}

/// Implements Stitch `farm_plots_soil_health_management`.
class FarmPlotsScreen extends StatelessWidget {
  const FarmPlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<FarmerSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Farm Plots & Soil Health'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Card(
            child: ListTile(
              title: Text('${s.farmName} • ${s.landArea} ${s.landUnit}'),
              subtitle: Text('Soil: ${s.soilType}\nIrrigation: ${s.waterSource}'),
              isThreeLine: true,
              trailing: const Icon(Icons.verified, color: AppColors.primary),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Plot B-2: Organic Spinach & Tomato'),
              subtitle: Text('pH 6.8 (Neutral) • NPK Balanced • Drip Active'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Implements Stitch `fpo_affiliation_land_settings`.
class FpoAffiliationScreen extends StatelessWidget {
  const FpoAffiliationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<FarmerSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'FPO Affiliation & Land'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Card(
            child: ListTile(
              title: const Text('Mulshi Valley Farmers Producer Co. Ltd.'),
              subtitle: Text('Hub: ${s.selectedHubName}\nOwnership: ${s.ownershipType}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.push('/collection-points'),
            child: const Text('Change Default Collection Hub'),
          ),
        ],
      ),
    );
  }
}
