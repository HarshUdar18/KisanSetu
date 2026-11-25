import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';

/// Implements Stitch:
/// - `onboarding_fresh_produce`
/// - `onboarding_direct_farmer_connection`
/// - `onboarding_weekly_delivery_planning`
class OnboardingScreen extends StatefulWidget {
  final int initialStep;

  const OnboardingScreen({super.key, this.initialStep = 0});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller;
  late int _page;

  static const List<Map<String, dynamic>> _slides = [
    {
      'badge': '12-HOUR HARVEST',
      'title': 'Farm Fresh Within 12 Hours',
      'subtitle':
          'Produce is harvested at 4:30 AM and reaches your kitchen by morning—crisp, chemical-free, and zero cold-storage aging.',
      'icon': Icons.wb_sunny_rounded,
      'highlight': 'Picked at Dawn • Delivered by 7 AM',
    },
    {
      'badge': 'DIRECT FPO BRIDGE',
      'title': 'Empowering Our Annadatas',
      'subtitle':
          'Every basket connects directly with 12,000+ farmer cooperatives across Pune, Nashik, and Baramati with transparent farmgate pricing.',
      'icon': Icons.handshake_rounded,
      'highlight': '80% Direct Farmer Payout',
    },
    {
      'badge': 'SMART KITCHEN PLANNER',
      'title': 'Plan Your Weekly Kitchen Basket',
      'subtitle':
          'Schedule Monday-to-Sunday vegetables and A2 milk ahead of time. Edit up to 1 time before the 9:00 PM dispatch cutoff.',
      'icon': Icons.calendar_month_rounded,
      'highlight': 'Flexible Mon–Sun Scheduling',
    },
  ];

  @override
  void initState() {
    super.initState();
    _page = widget.initialStep.clamp(0, _slides.length - 1);
    _controller = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await context.read<AppSettingsProvider>().completeOnboarding();
    if (!mounted) return;
    context.go('/location-primer');
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.level2,
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            size: 86,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            slide['badge'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onTertiaryFixed,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          slide['title'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          slide['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            slide['highlight'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.margin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.only(right: 6),
                        width: _page == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _page == i
                              ? AppColors.primaryContainer
                              : AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (isLast) {
                        _finishOnboarding();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                    label: Text(isLast ? 'Continue' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
