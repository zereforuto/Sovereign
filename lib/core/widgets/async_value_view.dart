import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/errors/failure.dart';
import 'package:sovereign/core/theme/colors.dart';

/// Reusable view for [AsyncValue] handling data, loading, and error states with a retry button.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: SovereignColors.rossoCorsa,
        ),
      ),
      error: (error, _) {
        final message = error is Failure
            ? error.message
            : error is Exception
                ? error.toString().replaceFirst('Exception: ', '')
                : error.toString();

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: SovereignColors.warning,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('RETRY'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
