import 'package:flutter/material.dart';

import '../archive/screens/zip_archive_page.dart';
import '../compression/screens/pdf_compression_page.dart';
import '../conversion/screens/document_conversion_page.dart';
import '../conversion/operations/popular_tools.dart';
import '../conversion/widgets/tool_shortcut_card.dart';
import 'widgets/home_header.dart';
import 'widgets/file_picker_card.dart';
import 'widgets/more_tools_page.dart';
import 'widgets/secondary_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.inbox_outlined),
      selectedIcon: Icon(Icons.inbox_rounded),
      label: 'Tray',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view_rounded),
      label: 'More',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildHome()
            : _selectedIndex == 2
            ? const MoreToolsPage()
            : SecondaryPage(
                label: _destinations[_selectedIndex].label,
                onBrowseTools: () => setState(() => _selectedIndex = 2),
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: _destinations,
      ),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              HomeHeader(
                onProfileTap: () => setState(() => _selectedIndex = 3),
              ),
              const SizedBox(height: 30),
              Text(
                'Your files,\n',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Transform.translate(
                offset: const Offset(0, -10),
                child: Text(
                  'ready for anything.',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: const Color(0xFF536DFE)),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -4),
                child: const Text(
                  'Your everyday file tools, all in one place.',
                ),
              ),
              const SizedBox(height: 22),
              FilePickerCard(
                onCompressPdf: () => openPdfCompressionPage(context),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Popular tools',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${popularTools.length} tools',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF536DFE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid.builder(
            itemCount: popularTools.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 126,
            ),
            itemBuilder: (context, index) {
              final tool = popularTools[index];
              return ToolShortcutCard(
                tool: tool,
                onTap: switch (tool.title) {
                  'Compress PDF' => () => openPdfCompressionPage(context),
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
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}
