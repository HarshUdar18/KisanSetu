import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `kisan_wallet_passbook` backed by `/api/v1/wallet`.
class KisanWalletScreen extends StatefulWidget {
  const KisanWalletScreen({super.key});

  @override
  State<KisanWalletScreen> createState() => _KisanWalletScreenState();
}

class _KisanWalletScreenState extends State<KisanWalletScreen> {
  double _balance = 0.0;
  String _currency = 'INR';
  List<Map<String, dynamic>> _transactions = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await context.read<DioClient>().get('/wallet');
      final data = res.data['data'] as Map<String, dynamic>? ?? {};
      final txns = (data['transactions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      if (mounted) {
        setState(() {
          _balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
          _currency = data['currency'] as String? ?? 'INR';
          _transactions = txns;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Unable to load wallet right now. Pull to retry.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Kisan Passbook Ledger'),
      body: RefreshIndicator(
        onRefresh: _loadWallet,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AVAILABLE WALLET BALANCE',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.tertiaryFixed,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('$_currency ${_balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const Text('Verified refunds & authorized credits appear here',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.onPrimaryContainer)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Recent Transactions',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_error != null)
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!)))
            else if (_transactions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No wallet transactions recorded yet.'),
                ),
              )
            else
              ..._transactions.map((txn) {
                final type = txn['transactionType'] as String? ?? 'CREDIT';
                final isDebit = type == 'DEBIT';
                final amount = (txn['amount'] as num?)?.toDouble() ?? 0.0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDebit ? AppColors.errorContainer : AppColors.secondaryContainer,
                      child: Icon(
                        isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isDebit ? AppColors.error : AppColors.primary,
                      ),
                    ),
                    title: Text(txn['description'] as String? ?? type),
                    subtitle: Text('$type • ${txn['status'] ?? 'COMPLETED'}'),
                    trailing: Text(
                      '${isDebit ? '-' : '+'}₹${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDebit ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Implements Stitch `harvest_impact_payout_ledger` backed by `/api/v1/fpos`.
class HarvestImpactScreen extends StatefulWidget {
  const HarvestImpactScreen({super.key});

  @override
  State<HarvestImpactScreen> createState() => _HarvestImpactScreenState();
}

class _HarvestImpactScreenState extends State<HarvestImpactScreen> {
  List<Map<String, dynamic>> _fpos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await context.read<DioClient>().get('/fpos');
      final raw = res.data['data'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _fpos = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Harvest Impact & Payout Ledger'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('VERIFIED COLLECTIVES',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.tertiaryFixed,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${_fpos.length} FPOs',
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const Text('Direct farmgate sourcing network',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.onPrimaryContainer)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (_fpos.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No FPO records available yet.'),
              ),
            )
          else
            ..._fpos.map((f) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.secondaryContainer,
                      child: Icon(Icons.agriculture,
                          color: AppColors.onSecondaryContainer),
                    ),
                    title: Text((f['name'] ?? '').toString()),
                    subtitle: Text('${f['district'] ?? ''}, ${f['state'] ?? ''}'),
                    trailing: Text((f['status'] ?? 'ACTIVE').toString()),
                  ),
                )),
        ],
      ),
    );
  }
}

/// Implements Stitch `seasonal_farm_visit_workshop`.
class FarmVisitScreen extends StatelessWidget {
  const FarmVisitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Seasonal Farm Visits'),
      body: const Padding(
        padding: EdgeInsets.all(AppSpacing.margin),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No seasonal farm visit workshops are scheduled yet.'),
          ),
        ),
      ),
    );
  }
}
