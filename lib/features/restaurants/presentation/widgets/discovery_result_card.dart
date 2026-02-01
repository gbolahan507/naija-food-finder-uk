import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/providers/discovery_provider.dart';

class DiscoveryResultCard extends StatelessWidget {
  final DiscoveryResult result;
  final VoidCallback? onTap;

  const DiscoveryResultCard({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final place = result.place;
    final isSelectable = !result.alreadyExists;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: result.isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: result.isSelected
              ? AppColors.primaryGreen
              : result.alreadyExists
                  ? AppColors.mediumGrey
                  : Colors.transparent,
          width: result.isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isSelectable ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: result.alreadyExists ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Checkbox or status icon
                _buildLeadingWidget(),
                const SizedBox(width: 12),

                // Restaurant info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and relevance badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (place.relevanceScore >= 8)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Best match',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Address
                      if (place.address != null)
                        Text(
                          place.address!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.lightText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 6),

                      // Rating and reviews
                      Row(
                        children: [
                          if (place.rating != null) ...[
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (place.userRatingsTotal != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(${place.userRatingsTotal} reviews)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.lightText,
                              ),
                            ),
                          ],
                          if (place.isOpen != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: place.isOpen!
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : AppColors.error.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                place.isOpen! ? 'Open' : 'Closed',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: place.isOpen!
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Already exists badge
                      if (result.alreadyExists) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mediumGrey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: AppColors.mediumGrey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Already in your collection',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mediumGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingWidget() {
    if (result.isAdding) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryGreen,
        ),
      );
    }

    if (result.alreadyExists) {
      return const Icon(
        Icons.check_circle,
        color: AppColors.mediumGrey,
        size: 24,
      );
    }

    return Checkbox(
      value: result.isSelected,
      onChanged: null, // Handled by InkWell
      activeColor: AppColors.primaryGreen,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
