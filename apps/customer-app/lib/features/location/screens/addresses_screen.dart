import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_gate.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/address_provider.dart';

/// Displays customer's saved addresses from backend with option to select active address.
class AddressesScreen extends StatefulWidget {
  final bool selectMode;

  const AddressesScreen({super.key, this.selectMode = false});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<AddressProvider>().fetchAddresses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<AddressProvider>();
    final addresses = provider.addresses;

    if (!auth.isAuthenticated) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        appBar: KisanStackAppBar(title: 'Saved Addresses'),
        body: GuestAuthRequiredView(
          icon: Icons.location_on_outlined,
          title: 'Sign in to view saved addresses',
          subtitle:
              'Verify your mobile number to access and manage your saved delivery addresses.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Saved Addresses'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/map-location'),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add New Address'),
      ),
      body: provider.isLoading && addresses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? EmptyStateView(
                  icon: Icons.location_off_outlined,
                  title: 'No Saved Addresses',
                  subtitle: 'Add your home or work address for farm-fresh delivery.',
                  actionLabel: 'Add Address',
                  onAction: () => context.push('/map-location'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  itemCount: addresses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      onTap: widget.selectMode
                          ? () => context.pop(addr)
                          : () async {
                              await provider.setDefaultAddress(addr.id);
                              if (!context.mounted) return;
                              await context
                                  .read<AppSettingsProvider>()
                                  .syncFromDefaultAddress(addr);
                              if (!context.mounted) return;
                              context.pop(addr);
                            },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: addr.isDefault
                                ? AppColors.primaryContainer
                                : AppColors.cardBorder,
                            width: addr.isDefault ? 1.8 : 1,
                          ),
                          boxShadow: AppShadows.level1,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  addr.label.toUpperCase() == 'WORK'
                                      ? Icons.work_outline
                                      : addr.label.toUpperCase() == 'HOME'
                                          ? Icons.home_outlined
                                          : Icons.place_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  addr.label,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                if (addr.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(AppRadius.full),
                                    ),
                                    child: const Text(
                                      'DEFAULT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                IconButton(
                                  tooltip: 'Delete address',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    final ok = await ConfirmationDialog.show(
                                      context,
                                      title: 'Delete Address?',
                                      message:
                                          'Remove "${addr.label}" (${addr.pincode}) from your saved addresses?',
                                      confirmLabel: 'Delete',
                                      isDestructive: true,
                                    );
                                    if (ok == true && context.mounted) {
                                      provider.deleteAddress(addr.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              addr.fullAddress,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (!addr.isDefault)
                                  TextButton(
                                    onPressed: () async {
                                      await provider.setDefaultAddress(addr.id);
                                      if (!context.mounted) return;
                                      await context
                                          .read<AppSettingsProvider>()
                                          .syncFromDefaultAddress(addr);
                                    },
                                    child: const Text('Set as Default'),
                                  ),
                                TextButton(
                                  onPressed: () =>
                                      context.push('/add-address', extra: addr),
                                  child: const Text('Edit'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
