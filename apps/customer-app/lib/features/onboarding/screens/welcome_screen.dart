import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

/// Implements Stitch `welcome_screen`.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(Icons.eco, color: AppColors.harvestGold, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text('Kisan Setu', style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/select-language'),
                    icon: const Icon(Icons.translate, size: 18),
                    label: const Text('Language'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: AppShadows.level2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixed,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Text(
                        'DIRECT FARM-TO-KITCHEN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onTertiaryFixed,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Pure, Farm-Fresh Produce at Honest Prices',
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Zero mandi middlemen. Harvested at dawn by verified Maharashtra & Karnataka FPOs and delivered within 12 hours.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TrustRow(
                icon: Icons.verified_outlined,
                title: '80% Direct Farmer Share',
                subtitle: 'Every rupee breakdown is transparently visible on your bill.',
              ),
              const SizedBox(height: 12),
              _TrustRow(
                icon: Icons.calendar_month_outlined,
                title: 'Monday-to-Sunday Weekly Basket',
                subtitle: 'Plan daily vegetables & A2 milk ahead so farmers harvest to order.',
              ),
              const SizedBox(height: 12),
              _TrustRow(
                icon: Icons.local_shipping_outlined,
                title: '9-Stage Supply Chain Tracking',
                subtitle: 'Follow your harvest from farm gate to quality lab to doorstep.',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/onboarding'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('I Already Have an Account (Login)'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.read<AuthProvider>().continueAsGuest();
                    context.go('/home');
                  },
                  child: const Text('Browse Fresh Produce as Guest'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
