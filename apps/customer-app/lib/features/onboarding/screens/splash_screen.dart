import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

/// Implements Stitch `splash_screen` design.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.28;
  String _statusText = 'Connecting Mandis...';
  Timer? _stageTimer;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  void _startSplashSequence() {
    _stageTimer = Timer(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      setState(() {
        _progress = 0.68;
        _statusText = 'Verifying Farm Batches...';
      });
    });

    _navTimer = Timer(const Duration(milliseconds: 1400), () async {
      if (!mounted) return;
      setState(() {
        _progress = 1.0;
        _statusText = 'Welcome to Kisan Setu';
      });
      final auth = context.read<AuthProvider>();
      final settings = context.read<AppSettingsProvider>();
      await Future.wait([auth.checkSession(), settings.loadSettings()]);
      if (!mounted) return;

      if (auth.isAuthenticated) {
        context.go('/home');
      } else if (!settings.onboardingSeen) {
        context.go('/select-language');
      } else {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle concentric circles background
            Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.margin),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top status pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco, size: 15, color: AppColors.tertiaryFixed),
                            SizedBox(width: 6),
                            Text(
                              'AGRI-DIRECT NETWORK',
                              style: TextStyle(
                                color: AppColors.tertiaryFixed,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: AppColors.secondaryFixed,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Live Hubs',
                              style: TextStyle(
                                color: AppColors.onPrimaryContainer,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Center Emblem & Brand Title
                  Column(
                    children: [
                      Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppShadows.level3,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.agriculture_rounded,
                                size: 52, color: AppColors.primary),
                            SizedBox(height: 4),
                            Icon(Icons.eco, size: 18, color: AppColors.harvestGold),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 18,
                            height: 1.5,
                            color: AppColors.tertiaryFixedDim.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            AppConstants.appTagline,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tertiaryFixed,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 18,
                            height: 1.5,
                            color: AppColors.tertiaryFixedDim.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 17, color: AppColors.tertiaryFixed),
                            SizedBox(width: 6),
                            Text(
                              'Govt. Recognized FPO Bridge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Bottom Impact Card & Harvest Gold Progress
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: const Icon(Icons.groups_rounded,
                                  color: AppColors.tertiaryFixed),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Empowering 50,000+ Farmers',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Across Maharashtra & Karnataka Clusters',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.onPrimaryContainer,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.military_tech,
                                size: 20, color: AppColors.tertiaryFixed),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: SizedBox(
                          width: 200,
                          height: 4,
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: AppColors.primaryContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.tertiaryFixed,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sync,
                                  size: 13, color: AppColors.tertiaryFixed),
                              const SizedBox(width: 6),
                              Text(
                                _statusText,
                                style: const TextStyle(
                                  color: AppColors.onPrimaryContainer,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            AppConstants.appVersion,
                            style: TextStyle(
                              color: AppColors.onPrimaryContainer,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
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
