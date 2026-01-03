import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Skeleton loading widget for RestaurantDetailsScreen
class RestaurantDetailsSkeleton extends StatelessWidget {
  const RestaurantDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          ShimmerLoading(
            child: ShimmerBox(
              width: MediaQuery.of(context).size.width,
              height: 250,
              borderRadius: BorderRadius.zero,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ShimmerLoading(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name
                  const ShimmerBox(
                    width: 200,
                    height: 24,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 12),

                  // Cuisine types
                  const ShimmerBox(
                    width: 150,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 16),

                  // Rating and reviews
                  Row(
                    children: [
                      const ShimmerBox(
                        width: 100,
                        height: 16,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      const SizedBox(width: 12),
                      const ShimmerBox(
                        width: 80,
                        height: 16,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section title
                  const ShimmerBox(
                    width: 120,
                    height: 18,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 12),

                  // Address
                  const ShimmerBox(
                    width: double.infinity,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  const ShimmerBox(
                    width: 180,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 24),

                  // About section
                  const ShimmerBox(
                    width: 100,
                    height: 18,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 12),
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
                    width: 220,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 24),

                  // Services chips
                  Row(
                    children: [
                      const ShimmerBox(
                        width: 80,
                        height: 32,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      const SizedBox(width: 8),
                      const ShimmerBox(
                        width: 90,
                        height: 32,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      const SizedBox(width: 8),
                      const ShimmerBox(
                        width: 70,
                        height: 32,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: 48,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: 48,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
