import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `raise_an_issue_ticket`.
class RaiseTicketScreen extends StatefulWidget {
  const RaiseTicketScreen({super.key});

  @override
  State<RaiseTicketScreen> createState() => _RaiseTicketScreenState();
}

class _RaiseTicketScreenState extends State<RaiseTicketScreen> {
  String _category = 'Order Issue';
  final _descCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Raise an Issue / Ticket'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: _submitted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.secondaryContainer,
                    child: Icon(Icons.check, size: 46, color: AppColors.onSecondaryContainer),
                  ),
                  const SizedBox(height: 16),
                  Text('Support Ticket #KS-T892 Created',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text(
                    'Our farm operations team will respond within 30 minutes.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Done'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Issue Category',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      'Order Issue',
                      'Payment Issue',
                      'Delivery Problem',
                      'Produce Quality',
                    ].map((c) {
                      return ChoiceChip(
                        label: Text(c),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Describe your issue',
                      hintText: 'Share order number or details...',
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _submitted = true),
                      child: const Text('Submit Support Request'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
