import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/farmer_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;
      final auth = context.read<FarmerAuthProvider>();
      final settings = context.read<FarmerSettingsProvider>();
      await Future.wait([auth.checkSession(), settings.loadSettings()]);
      if (!mounted) return;

      if (auth.isAuthenticated) {
        context.go('/dashboard');
      } else if (!settings.onboardingSeen) {
        context.go('/select-language');
      } else {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text(
                      'FARMER PRODUCER PORTAL',
                      style: TextStyle(
                        color: AppColors.tertiaryFixed,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Text(
                    AppConstants.appVersion,
                    style: TextStyle(color: AppColors.onPrimaryContainer, fontSize: 11),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppShadows.level3,
                    ),
                    child: const Icon(Icons.agriculture_rounded,
                        size: 56, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kisan Setu Farmer',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'शेतकरी समृद्धी • Direct Market & Escrow DBT',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tertiaryFixed,
                    ),
                  ),
                ],
              ),
              const LinearProgressIndicator(
                color: AppColors.tertiaryFixed,
                backgroundColor: AppColors.primaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
