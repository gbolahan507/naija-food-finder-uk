import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Skeleton loading widget for RestaurantCard
class RestaurantCardSkeleton extends StatelessWidget {
  const RestaurantCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ShimmerLoading(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              const ShimmerBox(
                width: 100,
                height: 100,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              const SizedBox(width: 12),

              // Content skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant name
                    const ShimmerBox(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    const SizedBox(height: 8),

                    // Cuisine types
                    const ShimmerBox(
                      width: 120,
                      height: 12,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    const SizedBox(height: 8),

                    // Rating row
                    Row(
                      children: [
                        const ShimmerBox(
                          width: 80,
                          height: 12,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        const SizedBox(width: 12),
                        const ShimmerBox(
                          width: 60,
                          height: 12,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Distance and status
                    Row(
                      children: [
                        const ShimmerBox(
                          width: 60,
                          height: 12,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        const SizedBox(width: 12),
                        const ShimmerBox(
                          width: 50,
                          height: 12,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
