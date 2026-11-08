import 'package:flutter/material.dart';

/// A reusable empty state widget with an icon, title, message, and optional action.
/// Uses SingleChildScrollView to prevent RenderFlex overflow on small screens or landscape mode.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(80),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 44.0,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6.0),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 16.0),
              FilledButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.add),
                label: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
