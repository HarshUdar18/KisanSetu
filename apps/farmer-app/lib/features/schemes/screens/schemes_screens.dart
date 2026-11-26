import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';

/// Module 16: Government Schemes, PM-KISAN, PMFBY & KCC backed by `/api/v1/schemes`.
class SchemesDashboardScreen extends StatefulWidget {
  const SchemesDashboardScreen({super.key});

  @override
  State<SchemesDashboardScreen> createState() => _SchemesDashboardScreenState();
}

class _SchemesDashboardScreenState extends State<SchemesDashboardScreen> {
  List<Map<String, dynamic>> _schemes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await context.read<DioClient>().get('/schemes');
      final raw = res.data['data'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _schemes = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Unable to load government schemes. Tap retry.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Government Schemes & Subsidies'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _loadSchemes, child: const Text('Retry')),
                    ],
                  ),
                )
              : _schemes.isEmpty
                  ? const Center(child: Text('No government schemes published yet.'))
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.margin),
                      children: _schemes
                          .map((s) => Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(14),
                                  leading: const CircleAvatar(
                                    backgroundColor: AppColors.secondaryContainer,
                                    child: Icon(Icons.account_balance,
                                        color: AppColors.onSecondaryContainer),
                                  ),
                                  title: Text((s['title'] ?? s['name'] ?? 'Scheme').toString(),
                                      style: Theme.of(context).textTheme.labelLarge),
                                  subtitle: Text(
                                      '${s['benefitSummary'] ?? s['description'] ?? ''}\n${s['status'] ?? 'ACTIVE'} • ${s['ministry'] ?? 'Govt of India'}'),
                                  isThreeLine: true,
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
