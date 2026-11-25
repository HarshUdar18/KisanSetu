import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Skeleton loading state matching Stitch `product_loading_skeleton`.
class ProductLoadingSkeleton extends StatelessWidget {
  const ProductLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.margin),
      children: [
        _shimmerBox(height: 50, radius: AppRadius.lg),
        const SizedBox(height: AppSpacing.md),
        _shimmerBox(height: 140, radius: AppRadius.xl),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                child: _shimmerBox(height: 76, radius: AppRadius.lg),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (_, __) => Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(height: 108, radius: AppRadius.lg),
                const SizedBox(height: 10),
                _shimmerBox(height: 12, width: 80),
                const SizedBox(height: 6),
                _shimmerBox(height: 16, width: 120),
                const Spacer(),
                _shimmerBox(height: 36, radius: AppRadius.md),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox({required double height, double? width, double radius = 6}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
