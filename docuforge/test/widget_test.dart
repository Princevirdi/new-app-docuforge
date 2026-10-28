import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:newdocuforge/app.dart';
import 'package:newdocuforge/features/conversion/operations/popular_tools.dart';

void main() {
  testWidgets('home exposes working document tools', (tester) async {
    await tester.pumpWidget(const DocuForgeApp());

    expect(find.text('12 tools'), findsOneWidget);
    expect(find.text('Start with PDF compression'), findsOneWidget);
    expect(find.text('Choose a PDF'), findsOneWidget);
    expect(popularTools.map((tool) => tool.title), [
      'View file',
      'Compress PDF',
      'Merge PDF',
      'Split PDF',
      'PDF to Word',
      'Word to PDF',
      'PDF to Excel',
      'Excel to PDF',
      'Image to PDF',
      'Zip files',
      'Unzip files',
      'Convert image',
    ]);
    expect(find.text('View file'), findsOneWidget);

    await tester.tap(find.text('Choose a PDF'));
    await tester.pumpAndSettle();
    expect(find.text('Make your PDF smaller'), findsOneWidget);
  });

  testWidgets('bottom navigation opens the tray page', (tester) async {
    await tester.pumpWidget(const DocuForgeApp());

    await tester.tap(find.text('Tray'));
    await tester.pumpAndSettle();

    expect(find.text('Your files, all in one place.'), findsOneWidget);
    expect(
      find.text('Your file tray is ready for a future update.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Browse tools'));
    await tester.pumpAndSettle();
    expect(find.text('All tools'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Your DocuForge profile.'), findsOneWidget);
    expect(find.textContaining('future update'), findsOneWidget);
  });

  testWidgets('More lists working document and archive tools', (tester) async {
    await tester.pumpWidget(const DocuForgeApp());

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('All tools'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(
      find.text(
        'PDF compression, PDF/Word conversion, and ZIP creation and extraction '
        'are ready to use. Other file tools are coming soon.',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Compress PDF'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Compress PDF'));
    await tester.pumpAndSettle();
    expect(find.text('Compression level'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Unzip files'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Unzip files'));
    await tester.pumpAndSettle();
    expect(find.text('Extract a ZIP archive'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Zip files'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zip files'));
    await tester.pumpAndSettle();
    expect(find.text('Create a ZIP archive'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('PDF to Word'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PDF to Word'));
    await tester.pumpAndSettle();
    expect(find.text('Preserve PDF pages in Word'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Word / DOCX'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Word / DOCX'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Images'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Images'), findsOneWidget);
  });
}
