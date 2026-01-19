import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable error state widget with retry functionality
class ErrorState extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorState({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  /// Error state for generic errors
  factory ErrorState.generic({
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      title: 'Something went wrong',
      message: 'An unexpected error occurred.\nPlease try again.',
      onRetry: onRetry,
    );
  }

  /// Error state for network errors
  factory ErrorState.network({
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      icon: Icons.wifi_off,
      title: 'Connection error',
      message:
          'Unable to connect to the server.\nCheck your connection and try again.',
      onRetry: onRetry,
    );
  }

  /// Error state for permission denied
  factory ErrorState.permissionDenied({
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      icon: Icons.lock_outline,
      title: 'Access denied',
      message: 'You don\'t have permission to access this.\nPlease try again.',
      onRetry: onRetry,
    );
  }

  /// Error state with custom message
  factory ErrorState.custom({
    required String error,
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      title: 'Error',
      message: error,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Error',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.lightText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
