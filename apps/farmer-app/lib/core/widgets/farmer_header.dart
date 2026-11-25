import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../providers/farmer_settings_provider.dart';
import '../theme/app_theme.dart';

/// Top sticky header matching Stitch `farmer_dashboard` & `my_produce_management`.
class FarmerTabHeader extends StatelessWidget implements PreferredSizeWidget {
  const FarmerTabHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FarmerSettingsProvider>();
    final auth = context.watch<FarmerAuthProvider>();
    final firstName = (auth.fullName ?? 'Ramesh').split(' ').first;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        boxShadow: AppShadows.level1,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Icon(Icons.agriculture,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => context.push('/select-farm-location'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Namaste, $firstName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 12, color: AppColors.primary),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                '${settings.village} FPO Cluster',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Bilingual EN / मरा Toggle Pill
                InkWell(
                  onTap: settings.toggleBilingual,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.translate,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          settings.languageCode == 'mr' ? 'मरा / EN' : 'EN / मरा',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () => context.push('/notifications'),
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColors.onSurfaceVariant),
                ),
                InkWell(
                  onTap: () => context.go('/profile'),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FarmerStackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const FarmerStackAppBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
      ),
      title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      actions: actions,
    );
  }
}
