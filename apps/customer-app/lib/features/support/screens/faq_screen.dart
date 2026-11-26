import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `faq_sourcing_knowledge_base`.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'How does Kisan Setu source directly from farmers?',
      'a': 'Produce is harvested by verified FPO farmer collectives and routed through regional collection hubs within 12 hours of harvest.',
    },
    {
      'q': 'When are weekly cart edits locked?',
      'a': 'Weekly cart adjustments are permitted within the configured pre-dispatch window before harvest allocation.',
    },
    {
      'q': 'How are refunds processed for cancelled orders?',
      'a': 'Approved refunds are initiated back to your original payment method or wallet.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'FAQ & Sourcing Knowledge Base'),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.margin),
        itemCount: _faqs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Card(
            child: ExpansionTile(
              title: Text(faq['q']!, style: Theme.of(context).textTheme.labelLarge),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(faq['a']!,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
