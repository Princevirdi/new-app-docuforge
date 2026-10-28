import 'package:flutter/material.dart';

class SecondaryPage extends StatelessWidget {
  const SecondaryPage({
    required this.label,
    required this.onBrowseTools,
    super.key,
  });

  final String label;
  final VoidCallback onBrowseTools;

  @override
  Widget build(BuildContext context) {
    if (label == 'Tray') return _buildTray(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF536DFE),
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your DocuForge profile.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontSize: 21),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your DocuForge profile will be available in a future update.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTray(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your files, all in one place.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your recent files will appear here in a future update.',
                ),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    color: Color(0xFF9AA2B4),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text('Your file tray is ready for a future update.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onBrowseTools,
                    icon: const Icon(Icons.grid_view_rounded),
                    label: const Text('Browse tools'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
