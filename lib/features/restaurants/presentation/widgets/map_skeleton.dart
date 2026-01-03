import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Skeleton loading widget for Map screen
class MapSkeleton extends StatelessWidget {
  const MapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Map placeholder
            Container(
              color: Colors.grey[200],
            ),

            // Bottom sheet skeleton
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const ShimmerBox(
                          width: 80,
                          height: 80,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ShimmerBox(
                                width: double.infinity,
                                height: 18,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              const SizedBox(height: 8),
                              const ShimmerBox(
                                width: 120,
                                height: 14,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const ShimmerBox(
                                    width: 80,
                                    height: 12,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                  ),
                                  const SizedBox(width: 12),
                                  const ShimmerBox(
                                    width: 60,
                                    height: 12,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 44,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 44,
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
      ),
    );
  }
}
