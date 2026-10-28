import 'package:flutter/material.dart';

import '../../archive/screens/zip_archive_page.dart';
import '../../compression/screens/pdf_compression_page.dart';
import '../../conversion/screens/document_conversion_page.dart';
import '../../conversion/models/tool_shortcut.dart';
import '../../conversion/operations/more_operations.dart';

class MoreToolsPage extends StatelessWidget {
  const MoreToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All tools',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Browse the tools planned for DocuForge.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF0FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF536DFE),
                        size: 19,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'PDF compression, PDF/Word conversion, and ZIP '
                          'creation and extraction are ready to use. Other '
                          'file tools are coming soon.',
                          style: TextStyle(
                            color: Color(0xFF394778),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        for (final category in moreOperationCategories)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(category.icon, color: category.color, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        category.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      Text(
                        '${category.tools.length}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    itemCount: category.tools.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 92,
                        ),
                    itemBuilder: (context, index) {
                      final tool = category.tools[index];
                      return _ToolTile(
                        tool: tool,
                        onTap: switch (tool.title) {
                          'Compress PDF' => () => openPdfCompressionPage(
                            context,
                          ),
                          'PDF to Word' => () => openDocumentConversionPage(
                            context,
                            DocumentConversionDirection.pdfToWord,
                          ),
                          'Word to PDF' => () => openDocumentConversionPage(
                            context,
                            DocumentConversionDirection.wordToPdf,
                          ),
                          'Zip files' => () => openZipArchivePage(
                            context,
                            ZipArchiveOperation.create,
                          ),
                          'Unzip files' => () => openZipArchivePage(
                            context,
                            ZipArchiveOperation.extract,
                          ),
                          _ => null,
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool, this.onTap});

  final ToolShortcut tool;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F2F6),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE8EBF3)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tool.color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tool.icon,
                  color: onTap == null ? const Color(0xFF9AA2B4) : tool.color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onTap == null
                            ? const Color(0xFF858C9C)
                            : const Color(0xFF202A43),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      onTap == null ? 'Coming soon' : 'Ready',
                      style: TextStyle(
                        color: onTap == null
                            ? const Color(0xFF858C9C)
                            : const Color(0xFF42A878),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9AA2B4),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
