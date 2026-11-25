import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/farmer_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';

class SelectLanguageScreen extends StatelessWidget {
  final bool fromSettings;

  const SelectLanguageScreen({super.key, this.fromSettings = false});

  static const _langs = [
    {'code': 'en', 'name': 'English', 'native': 'English (India)'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी (शेतकरी पोर्टल)'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी (किसान पोर्टल)'},
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FarmerSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: fromSettings ? const FarmerStackAppBar(title: 'Language') : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Choose Your Language / भाषा निवडा',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              ..._langs.map((l) {
                final sel = settings.languageCode == l['code'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text('${l['native']}'),
                    subtitle: Text(l['name']!),
                    trailing: Icon(
                      sel ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: sel ? AppColors.primary : AppColors.outline,
                    ),
                    onTap: () => settings.setLanguage(l['code']!),
                  ),
                );
              }),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      fromSettings ? context.pop() : context.go('/welcome'),
                  child: Text(fromSettings ? 'Save Language' : 'Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIRECT MARKET ACCESS FOR FARMERS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tertiaryFixed,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sell Harvest Directly with Escrow-Protected DBT Payouts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Zero mandi commission agents. Pre-confirmed urban demand, transparent APMC lab grading, and weekly Friday bank settlements.',
                      style: TextStyle(color: AppColors.onPrimaryContainer, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const ListTile(
                leading: Icon(Icons.verified_user, color: AppColors.primary),
                title: Text('Digital Farmer KYC & 7/12 Verification'),
                subtitle: Text('RBI Escrow DBT directly to your bank account'),
              ),
              const ListTile(
                leading: Icon(Icons.eco, color: AppColors.primary),
                title: Text('List Produce Lots & Surplus Batches'),
                subtitle: Text('Set your own farmgate price and harvest date'),
              ),
              const ListTile(
                leading: Icon(Icons.local_shipping, color: AppColors.primary),
                title: Text('Collection Hubs & Cold-Chain Logistics'),
                subtitle: Text('Book dawn gate passes & track weighbridge slips'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/onboarding'),
                  child: const Text('Get Started (New Farmer)'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Farmer Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _idx = 0;

  static const _pages = [
    {
      'title': 'Direct Market Access',
      'desc': 'Connect directly with urban housing societies and bulk FPO buyers without intermediaries.',
      'icon': Icons.storefront_rounded,
    },
    {
      'title': 'Produce & Surplus Selling',
      'desc': 'Publish harvest lots, accept buyer demand requests, or clear surplus batches quickly.',
      'icon': Icons.eco_rounded,
    },
    {
      'title': 'Collection & Quality Lab',
      'desc': 'Book morning collection slots, receive digital tare slips, and transparent APMC lab grade cards.',
      'icon': Icons.qr_code_scanner_rounded,
    },
    {
      'title': 'Weekly DBT Settlements',
      'desc': 'Every dispatch is escrow-protected and settled directly to your linked bank account every Friday.',
      'icon': Icons.account_balance_wallet_rounded,
    },
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _idx == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await context.read<FarmerSettingsProvider>().completeOnboarding();
                  if (!context.mounted) return;
                  context.go('/location-primer');
                },
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _idx = i),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: AppColors.surfaceContainer,
                        child: Icon(_pages[i]['icon'] as IconData,
                            size: 64, color: AppColors.primary),
                      ),
                      const SizedBox(height: 24),
                      Text(_pages[i]['title'] as String,
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Text(_pages[i]['desc'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.margin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: _idx == i ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _idx == i
                              ? AppColors.primary
                              : AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (isLast) {
                        await context
                            .read<FarmerSettingsProvider>()
                            .completeOnboarding();
                        if (!context.mounted) return;
                        context.go('/location-primer');
                      } else {
                        _ctrl.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Text(isLast ? 'Continue' : 'Next'),
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
