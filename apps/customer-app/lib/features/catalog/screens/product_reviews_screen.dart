import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `product_review_farmer_feedback`.
class ProductReviewsScreen extends StatefulWidget {
  final String productId;

  const ProductReviewsScreen({super.key, required this.productId});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  final List<Map<String, dynamic>> _reviews = [
    {
      'author': 'Ananya Sharma',
      'rating': 5,
      'date': 'Today, 8:10 AM',
      'comment': 'Super crisp and sweet! Arrived at 6:40 AM with zero plastic packaging.',
    },
    {
      'author': 'Rohan Kulkarni',
      'rating': 5,
      'date': '2 days ago',
      'comment': 'Knowing 80% goes straight to Ramesh ji at Junnar FPO makes this unbeatable.',
    },
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Product Review & Farmer Feedback'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How was today's dawn harvest from Ramesh Shinde?",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (i) {
                      return IconButton(
                        onPressed: () => setState(() => _rating = i + 1),
                        icon: Icon(
                          i < _rating ? Icons.star : Icons.star_border,
                          color: AppColors.harvestGold,
                          size: 30,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Share freshness feedback or a thank-you note for the farmer...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_commentCtrl.text.trim().isEmpty) return;
                        setState(() {
                          _reviews.insert(0, {
                            'author': 'You',
                            'rating': _rating,
                            'date': 'Just now',
                            'comment': _commentCtrl.text.trim(),
                          });
                          _commentCtrl.clear();
                        });
                      },
                      child: const Text('Submit Feedback to Farmer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Recent Verified Reviews',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ..._reviews.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r['author'] as String,
                              style: Theme.of(context).textTheme.labelLarge),
                          Text(r['date'] as String,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('★' * (r['rating'] as int),
                          style: const TextStyle(color: AppColors.harvestGold)),
                      const SizedBox(height: 6),
                      Text(r['comment'] as String,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
