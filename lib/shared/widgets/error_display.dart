import 'package:flutter/material.dart';
import '../utils/api_error_handler.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final ErrorType? errorType;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final EdgeInsets padding;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.errorType,
    this.onRetry,
    this.showRetryButton = true,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildErrorIcon(),
          const SizedBox(height: 12),
          Text(
            _getErrorTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(height: 16),
            _buildRetryButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorIcon() {
    IconData iconData;
    Color iconColor;

    switch (errorType) {
      case ErrorType.network:
        iconData = Icons.wifi_off;
        iconColor = Colors.orange;
        break;
      case ErrorType.authentication:
        iconData = Icons.lock_outline;
        iconColor = Colors.red;
        break;
      case ErrorType.notFound:
        iconData = Icons.search_off;
        iconColor = Colors.blue;
        break;
      case ErrorType.server:
        iconData = Icons.cloud_off;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.error_outline;
        iconColor = Colors.grey;
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 32,
        color: iconColor,
      ),
    );
  }

  String _getErrorTitle() {
    switch (errorType) {
      case ErrorType.network:
        return 'Connection Problem';
      case ErrorType.authentication:
        return 'Authentication Required';
      case ErrorType.notFound:
        return 'Not Found';
      case ErrorType.server:
        return 'Server Error';
      default:
        return 'Something Went Wrong';
    }
  }

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text('Try Again'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF007399),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Compact error display for dropdowns and small spaces
class CompactErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CompactErrorDisplay({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error display for form fields and dropdowns
class FieldErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const FieldErrorDisplay({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // Same height as form fields
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  iconSize: 18,
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
