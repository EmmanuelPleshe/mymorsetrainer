import 'package:flutter/material.dart';

/// Reusable AppBar for non-home screens.
///
/// - Leading: back arrow icon that navigates to home ('/')
/// - Actions: optional nav icons (Practice, Progress, Settings) when bottom nav is hidden
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNavIcons;
  final Future<void> Function()? onHomePressed;
  final List<Widget>? extraActions;

  const HomeAppBar({
    super.key,
    required this.title,
    this.showNavIcons = false,
    this.onHomePressed,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Home',
        onPressed: () async {
          if (onHomePressed != null) {
            await onHomePressed!();
          }
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        },
      ),
      actions: [
        if (extraActions != null) ...extraActions!,
        if (showNavIcons) ...[
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Practice',
            onPressed: () => Navigator.pushNamed(context, '/practice'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Progress',
            onPressed: () => Navigator.pushNamed(context, '/progress'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
