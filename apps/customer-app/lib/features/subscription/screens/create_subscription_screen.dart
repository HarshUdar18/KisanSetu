import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../location/providers/address_provider.dart';
import '../providers/subscription_provider.dart';

/// Implements Stitch `create_subscription`.
class CreateSubscriptionScreen extends StatefulWidget {
  const CreateSubscriptionScreen({super.key});

  @override
  State<CreateSubscriptionScreen> createState() =>
      _CreateSubscriptionScreenState();
}

class _CreateSubscriptionScreenState extends State<CreateSubscriptionScreen> {
  String _selectedPlan = 'Pure A2 Gir Cow Milk (1L) + Fresh Greens';
  String _frequency = 'DAILY';
  String _slot = 'Morning Harvest (6:00 AM - 8:00 AM)';

  static const _plans = [
    {'title': 'Pure A2 Gir Cow Milk (1L) + Fresh Greens', 'price': 117.0},
    {'title': 'Family Weekly Organic Veggie Box (5kg)', 'price': 540.0},
    {'title': 'Seasonal Fruit & Immunity Basket', 'price': 360.0},
  ];

  @override
  Widget build(BuildContext context) {
    final addr = context.watch<AddressProvider>().defaultAddress;
    final subProvider = context.watch<SubscriptionProvider>();
    final planPrice = (_plans
            .firstWhere((p) => p['title'] == _selectedPlan)['price'] as num)
        .toDouble();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Create Subscription'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Text('Choose Produce & Plan',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          ..._plans.map((p) {
            final title = p['title'] as String;
            final selected = title == _selectedPlan;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: RadioListTile<String>(
                value: title,
                groupValue: _selectedPlan,
                onChanged: (v) => setState(() => _selectedPlan = v!),
                title: Text(title, style: Theme.of(context).textTheme.labelLarge),
                subtitle: Text('₹${(p['price'] as num).toStringAsFixed(0)} per delivery'),
                selected: selected,
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Text('Delivery Frequency',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['DAILY', 'ALTERNATE_DAYS', 'WEEKLY', 'BIWEEKLY'].map((f) {
              return ChoiceChip(
                label: Text(f.replaceAll('_', ' ')),
                selected: _frequency == f,
                onSelected: (_) => setState(() => _frequency = f),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Morning Slot', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              'Morning Harvest (6:00 AM - 8:00 AM)',
              'Mid-Morning (8:00 AM - 10:00 AM)',
            ].map((s) {
              return ChoiceChip(
                label: Text(s),
                selected: _slot == s,
                onSelected: (_) => setState(() => _slot = s),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: subProvider.isLoading
                  ? null
                  : () async {
                      await subProvider.createSubscription(
                        title: _selectedPlan,
                        frequency: _frequency,
                        addressId: addr?.id ?? 'addr-1',
                        totalPerCycle: planPrice,
                        deliveryPreferences: _slot,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Subscription Confirmed! First delivery tomorrow.'),
                        ),
                      );
                      context.pop();
                    },
              child: Text(
                  'Confirm Subscription • ₹${planPrice.toStringAsFixed(0)}/cycle'),
            ),
          ),
        ],
      ),
    );
  }
}
