import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/subscription_provider.dart';

/// Implements Stitch `edit_delivery_schedule_frequency`.
class EditScheduleScreen extends StatefulWidget {
  final String subscriptionId;

  const EditScheduleScreen({super.key, required this.subscriptionId});

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  String _frequency = 'DAILY';
  String _slot = 'Morning Harvest (6:00 AM - 8:00 AM)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Edit Delivery Schedule'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery Frequency',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
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
            const SizedBox(height: AppSpacing.lg),
            Text('Preferred Time Slot',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            RadioGroup<String>(
              groupValue: _slot,
              onChanged: (v) {
                if (v != null) setState(() => _slot = v);
              },
              child: Column(
                children: [
                  'Morning Harvest (6:00 AM - 8:00 AM)',
                  'Mid-Morning (8:00 AM - 10:00 AM)',
                  'Evening Fresh (5:00 PM - 7:00 PM)',
                ]
                    .map((s) => RadioListTile<String>(
                          value: s,
                          title: Text(s),
                        ))
                    .toList(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<SubscriptionProvider>()
                      .updateSchedule(widget.subscriptionId, _frequency, _slot);
                  context.pop();
                },
                child: const Text('Update Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
