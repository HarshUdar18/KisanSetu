import 'package:flutter/material.dart';
import '../../../core/services/mock_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `faq_sourcing_knowledge_base`.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'FAQ & Sourcing Knowledge Base'),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.margin),
        itemCount: MockCustomerServices.faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final faq = MockCustomerServices.faqs[index];
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
