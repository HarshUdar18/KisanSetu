import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settlements_provider.dart';

/// Implements Stitch `weekly_settlements_passbook`.
class WeeklySettlementsScreen extends StatelessWidget {
  const WeeklySettlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settlements = context.watch<SettlementsProvider>();
    final auth = context.watch<FarmerAuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerTabHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WEEKLY PAYOUT BALANCE (SCHEDULED FRIDAY)',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryContainer)),
                const SizedBox(height: 6),
                Text(
                  '₹${settlements.weeklyBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  '${auth.bankName} (${auth.bankAccountMasked}) • IFSC ${auth.ifsc}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.onPrimaryContainer),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryContainer,
                          foregroundColor: AppColors.onSecondaryContainer,
                        ),
                        onPressed: () => context.push('/wallet'),
                        child: const Text('Kisan Wallet'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        onPressed: () => context.push('/finance/invoice'),
                        child: const Text('Tax Invoice'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('DBT Escrow Ledger'),
                onPressed: () => context.push('/settlements/dbt-ledger'),
              ),
              ActionChip(
                label: const Text('Annual P&L Sheet'),
                onPressed: () => context.push('/finance/balance-sheet'),
              ),
              ActionChip(
                label: const Text('Crop Profit Margin'),
                onPressed: () => context.push('/finance/crop-profit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Farmer Passbook Ledger',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ...settlements.ledger.map((e) {
            final isCredit = e['isCredit'] == true;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(e['title'] as String,
                    style: Theme.of(context).textTheme.labelLarge),
                subtitle: Text('${e['subtitle']}\n${e['date']} • ${e['status']}'),
                isThreeLine: true,
                trailing: Text(
                  '${isCredit ? '+' : ''}₹${(e['amount'] as num).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isCredit ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class PassbookStatementsScreen extends StatelessWidget {
  const PassbookStatementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Settlement Passbook Statements'),
      body: const Center(child: Text('Monthly & Weekly Statements')),
    );
  }
}

class DbtEscrowLedgerScreen extends StatelessWidget {
  const DbtEscrowLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'DBT Escrow Transit Ledger'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('Escrow #ESC-8821 • Locked'),
              subtitle: Text('Kothrud Urban Society -> Scheduled Friday DBT'),
              trailing: Text('₹4,560',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class KisanWalletScreen extends StatelessWidget {
  const KisanWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettlementsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Kisan Wallet Financial Overview'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text('₹${s.walletBalance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium),
                subtitle: const Text('Available Farmer Wallet Balance'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/wallet/withdraw'),
                child: const Text('Request Bank Transfer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BankWithdrawalScreen extends StatefulWidget {
  const BankWithdrawalScreen({super.key});

  @override
  State<BankWithdrawalScreen> createState() => _BankWithdrawalScreenState();
}

class _BankWithdrawalScreenState extends State<BankWithdrawalScreen> {
  final _amtCtrl = TextEditingController(text: '1000');

  @override
  void dispose() {
    _amtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Bank Transfer Request'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          children: [
            TextField(
              controller: _amtCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Transfer Amount (₹)'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(_amtCtrl.text) ?? 0;
                  context
                      .read<SettlementsProvider>()
                      .requestWalletWithdrawal(amt);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Transfer initiated; awaiting bank settlement.')),
                  );
                  context.pop();
                },
                child: const Text('Submit Transfer Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FarmerTaxInvoiceScreen extends StatelessWidget {
  const FarmerTaxInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Farmer Sales Receipt'),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: ListTile(
            title: Text('शेतमाल विक्री पावती • #INV-2026-44'),
            subtitle: Text('Direct Produce Sale • Logistics & handling itemized per backend ledger.'),
          ),
        ),
      ),
    );
  }
}

class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Annual Farm Balance Sheet (P&L)'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('Total Gross Harvest Revenue (FY 2025-26)'),
              trailing: Text('₹4,82,500',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Input & Cultivation Costs'),
              trailing: Text('₹1,64,200'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Net Farm Surplus'),
              trailing: Text('₹3,18,300',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class CropProfitScreen extends StatelessWidget {
  const CropProfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Crop-Wise Profit Margin'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('Baby Spinach (पालक)'),
              subtitle: Text('Cost: ₹14/kg • Avg Realization: ₹38/kg'),
              trailing: Text('+63% Margin',
                  style: TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
