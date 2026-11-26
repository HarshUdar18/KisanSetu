import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/subscription_provider.dart';

/// Implements Stitch `pause_subscription_vacation_mode`.
class PauseSubscriptionScreen extends StatefulWidget {
  final String subscriptionId;

  const PauseSubscriptionScreen({super.key, required this.subscriptionId});

  @override
  State<PauseSubscriptionScreen> createState() =>
      _PauseSubscriptionScreenState();
}

class _PauseSubscriptionScreenState extends State<PauseSubscriptionScreen> {
  String _duration = '7 Days (Back Next Week)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Pause & Vacation Mode'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Going Away? Pause Deliveries',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'We will notify your FPO farmer in advance so zero produce is wasted.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            RadioGroup<String>(
              groupValue: _duration,
              onChanged: (v) {
                if (v != null) setState(() => _duration = v);
              },
              child: Column(
                children: [
                  '3 Days (Weekend Trip)',
                  '7 Days (Back Next Week)',
                  '14 Days (Extended Vacation)',
                  'Until I Resume Manually',
                ]
                    .map((opt) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: RadioListTile<String>(
                            value: opt,
                            title: Text(opt),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<SubscriptionProvider>().pauseSubscription(
                        widget.subscriptionId,
                        resumeDate: 'Paused ($_duration)',
                      );
                  context.pop();
                },
                child: const Text('Activate Vacation Mode'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
