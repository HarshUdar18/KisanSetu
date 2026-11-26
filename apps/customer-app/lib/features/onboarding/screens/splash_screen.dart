import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../location/providers/address_provider.dart';

/// Clean branding-only Splash Screen:
/// Splash Screen -> Phone Number Screen (or restored session).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _minDisplayTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _resolveStartup();
  }

  Future<void> _resolveStartup() async {
    final auth = context.read<AuthProvider>();
    final settings = context.read<AppSettingsProvider>();
    final addressProvider = context.read<AddressProvider>();

    final minDelay = Completer<void>();
    _minDisplayTimer = Timer(const Duration(milliseconds: 650), () {
      if (!minDelay.isCompleted) minDelay.complete();
    });

    await Future.wait([
      auth.checkSession(),
      settings.loadSettings(),
      minDelay.future,
    ]);
    if (!mounted || _navigated) return;

    if (auth.isAuthenticated) {
      await addressProvider.fetchAddresses();
      if (!mounted || _navigated) return;
      if (addressProvider.addresses.isNotEmpty) {
        await settings.syncFromDefaultAddress(addressProvider.defaultAddress);
        if (!mounted || _navigated) return;
        _go('/home');
      } else if (settings.isLocationSkipped || settings.isLocationSelected) {
        _go('/home');
      } else {
        _go('/select-location');
      }
    } else {
      _go('/login');
    }
  }

  void _go(String route) {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go(route);
  }

  @override
  void dispose() {
    _minDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Image.asset(
              AppAssets.wordmark,
              width: 240,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
