import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/mock_farmer_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';

/// Module 16: Government Schemes, PM-KISAN, PMFBY & KCC.
class SchemesDashboardScreen extends StatelessWidget {
  const SchemesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Government Schemes & Subsidies'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: MockFarmerServices.govtSchemes
            .map((s) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.secondaryContainer,
                      child: Icon(Icons.account_balance,
                          color: AppColors.onSecondaryContainer),
                    ),
                    title: Text(s['title'] as String,
                        style: Theme.of(context).textTheme.labelLarge),
                    subtitle: Text(
                        '${s['amount']}\n${s['status']} • ${s['source']}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(s['route'] as String),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class PmKisanTrackerScreen extends StatelessWidget {
  const PmKisanTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'PM-KISAN DBT Tracker'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('18th Installment • ₹2,000'),
              subtitle: Text('Credited via NPCI Aadhaar DBT • SBI ••••4201\nSource: pmkisan.gov.in'),
              isThreeLine: true,
              trailing: Chip(label: Text('Credited')),
            ),
          ),
        ],
      ),
    );
  }
}

class PmfbyInsuranceScreen extends StatelessWidget {
  const PmfbyInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'PMFBY Crop Insurance'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('PMFBY पीक संरक्षण • Rabi 2026'),
              subtitle: Text('Sum Insured: ₹1,20,000 • Premium Paid: ₹1,800\nSource: pmfby.gov.in'),
              isThreeLine: true,
              trailing: Chip(label: Text('Active')),
            ),
          ),
        ],
      ),
    );
  }
}

class KccTrackerScreen extends StatelessWidget {
  const KccTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Kisan Credit Card (KCC)'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('Bank of Maharashtra KCC • MH-PUN-KCC-99214'),
              subtitle: Text('Sanctioned Limit: ₹3,00,000 • Effective Rate: 4% p.a. (with 3% subvention)'),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }
}
