import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_gate.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/weekly_cart_provider.dart';

/// Implements Stitch `weekly_cart_planner` (Mon–Sun dashboard + single-edit rule).
class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<WeeklyCartProvider>().fetchWeeklyCarts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        appBar: KisanTabHeader(),
        body: GuestAuthRequiredView(
          icon: Icons.calendar_month_outlined,
          title: 'Sign in to plan your Weekly Basket',
          subtitle:
              'Schedule Monday-to-Sunday fresh vegetables and A2 milk deliveries.',
        ),
      );
    }
    final provider = context.watch<WeeklyCartProvider>();
    final cart = provider.activeWeeklyCart;
    final selectedDay = provider.selectedDay;
    final dayPlan = provider.getDayPlan(selectedDay);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanTabHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Text(
            'Weekly Kitchen Basket',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Schedule your fresh vegetables and dairy deliveries by day. Edit anytime until 9 PM the previous night.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),

          // Week Selector Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.chevron_left),
                Column(
                  children: [
                    Text(
                      cart?.title ?? 'Week 44 Kitchen Basket',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${cart?.status ?? 'DRAFT'} • EDITS ${cart?.modificationCount ?? 0}/1',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Mon-Sun Day Chips
          SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: WeeklyCartProvider.daysOrder.map((day) {
                final isSelected = day == selectedDay;
                final plan = provider.getDayPlan(day);
                final hasItems = plan != null && plan.items.isNotEmpty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => provider.selectDay(day),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.substring(0, 3),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CircleAvatar(
                            radius: 3.5,
                            backgroundColor: hasItems
                                ? (isSelected
                                      ? AppColors.harvestGold
                                      : AppColors.secondary)
                                : AppColors.outlineVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Selected Day Items Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$selectedDay Plan (${dayPlan?.items.length ?? 0} items)',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton.icon(
                onPressed: () =>
                    context.push('/weekly-planner/day/$selectedDay'),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Day'),
              ),
            ],
          ),
          if (dayPlan == null || dayPlan.items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rest Day • No delivery scheduled'),
                    ElevatedButton(
                      onPressed: () =>
                          context.push('/weekly-planner/day/$selectedDay'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 38),
                      ),
                      child: const Text('+ Add Items'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...dayPlan.items.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceContainer,
                    child: Icon(Icons.eco, color: AppColors.primary, size: 20),
                  ),
                  title: Text(
                    item.productName,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  subtitle: Text(
                    '${item.quantity.toStringAsFixed(0)} × ${item.unit}',
                  ),
                  trailing: Text(
                    '₹${item.totalPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A submitted weekly cart can be corrected only once before dispatch cutoff.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Weekly Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: AppShadows.level1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'WEEKLY SUMMARY',
                      style: TextStyle(fontSize: 11, color: AppColors.outline),
                    ),
                    Text(
                      '${cart?.days.where((d) => d.items.isNotEmpty).length ?? 0} Deliveries Planned',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${cart?.weeklyEstimatedTotal.toStringAsFixed(0) ?? '0'}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (cart?.status == 'DRAFT') {
                        await provider.submitWeeklyCart();
                      }
                      if (!context.mounted) return;
                      context.push('/weekly-planner/submitted');
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      cart?.status == 'DRAFT'
                          ? 'Submit Weekly Schedule'
                          : 'View Submission & Edit Status',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
