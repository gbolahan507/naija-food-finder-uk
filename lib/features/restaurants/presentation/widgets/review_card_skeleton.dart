import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Skeleton loading widget for Review cards
class ReviewCardSkeleton extends StatelessWidget {
  const ReviewCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ShimmerLoading(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info row
              Row(
                children: [
                  // Avatar
                  const ShimmerCircle(size: 40),
                  const SizedBox(width: 12),

                  // User name and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerBox(
                          width: 120,
                          height: 14,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        const SizedBox(height: 6),
                        const ShimmerBox(
                          width: 80,
                          height: 12,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ],
                    ),
                  ),

                  // Rating
                  const ShimmerBox(
                    width: 60,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Review text
              const ShimmerBox(
                width: double.infinity,
                height: 14,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              const SizedBox(height: 8),
              const ShimmerBox(
                width: double.infinity,
                height: 14,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              const SizedBox(height: 8),
              const ShimmerBox(
                width: 200,
                height: 14,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
