import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:newdocuforge/features/conversion/services/document_conversion_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  late DocumentConversionService service;

  setUp(() {
    service = DocumentConversionService();
  });

  test(
    'preserves a PDF page as a high-resolution image in a valid DOCX',
    () async {
      final pdf = PdfDocument();
      final page = pdf.pages.add();
      page.graphics.drawString(
        'Preserved text & symbols',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
      );
      page.graphics.drawRectangle(
        bounds: const Rect.fromLTWH(20, 40, 100, 50),
        brush: PdfSolidBrush(PdfColor(220, 30, 30)),
      );
      pdf.pages.add().graphics.drawString(
        'Second page content',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
      );
      final input = Uint8List.fromList(await pdf.save());
      pdf.dispose();

      final output = await service.pdfToDocx(input);
      final archive = ZipDecoder().decodeBytes(output);
      final document = archive.findFile('word/document.xml');
      final pageImage = archive.findFile('word/media/page_1.png');
      final secondPageImage = archive.findFile('word/media/page_2.png');
      final relationships = archive.findFile('word/_rels/document.xml.rels');

      expect(document, isNotNull);
      expect(pageImage, isNotNull);
      expect(secondPageImage, isNotNull);
      expect(relationships, isNotNull);
      expect(utf8.decode(document!.content), contains('<w:drawing>'));
      expect(
        utf8.decode(document.content),
        contains('Rendered image of PDF page 1'),
      );
      expect(utf8.decode(document.content), contains('w:type="page"'));
      expect(
        utf8.decode(relationships!.content),
        contains('Target="media/page_2.png"'),
      );
      final decodedImage = image.decodePng(pageImage!.content);
      expect(decodedImage, isNotNull);
      expect(decodedImage!.width, greaterThan(500));
      expect(decodedImage.height, greaterThan(500));
    },
  );

  test('converts DOCX paragraphs and table text into a readable PDF', () {
    final output = service.docxToPdf(
      _createDocx(
        '<w:p><w:r><w:t>Document text</w:t></w:r></w:p>'
        '<w:tbl><w:tr>'
        '<w:tc><w:p><w:r><w:t>First cell</w:t></w:r></w:p></w:tc>'
        '<w:tc><w:p><w:r><w:t>Second cell</w:t></w:r></w:p></w:tc>'
        '</w:tr></w:tbl>',
      ),
    );

    final pdf = PdfDocument(inputBytes: output);
    try {
      final text = PdfTextExtractor(pdf).extractText();
      expect(text, contains('Document text'));
      expect(text, contains('First cell'));
      expect(text, contains('Second cell'));
    } finally {
      pdf.dispose();
    }
  });

  test('rejects invalid input formats', () {
    expect(
      service.pdfToDocx(Uint8List.fromList('not a PDF'.codeUnits)),
      throwsFormatException,
    );
    expect(
      () => service.docxToPdf(Uint8List.fromList('not a DOCX'.codeUnits)),
      throwsFormatException,
    );
  });

  test('rejects documents containing media rather than dropping it', () {
    final archive = Archive()
      ..addFile(
        ArchiveFile.string(
          'word/document.xml',
          '<w:document xmlns:w="http://schemas.openxmlformats.org/'
              'wordprocessingml/2006/main"><w:body>'
              '<w:p><w:r><w:drawing/></w:r></w:p>'
              '</w:body></w:document>',
        ),
      );
    final input = Uint8List.fromList(ZipEncoder().encode(archive));

    expect(() => service.docxToPdf(input), throwsFormatException);
  });

  test('rejects documents containing header text rather than dropping it', () {
    final archive = Archive()
      ..addFile(
        ArchiveFile.string(
          'word/document.xml',
          '<w:document xmlns:w="http://schemas.openxmlformats.org/'
              'wordprocessingml/2006/main"><w:body>'
              '<w:p><w:r><w:t>Body</w:t></w:r></w:p>'
              '</w:body></w:document>',
        ),
      )
      ..addFile(
        ArchiveFile.string(
          'word/header1.xml',
          '<w:hdr xmlns:w="http://schemas.openxmlformats.org/'
              'wordprocessingml/2006/main"><w:p><w:r><w:t>Header</w:t>'
              '</w:r></w:p></w:hdr>',
        ),
      );
    final input = Uint8List.fromList(ZipEncoder().encode(archive));

    expect(() => service.docxToPdf(input), throwsFormatException);
  });
}

Uint8List _createDocx(String bodyContent) {
  final archive = Archive()
    ..addFile(
      ArchiveFile.string(
        'word/document.xml',
        '<w:document xmlns:w="http://schemas.openxmlformats.org/'
            'wordprocessingml/2006/main"><w:body>$bodyContent'
            '<w:sectPr/></w:body></w:document>',
      ),
    );
  return Uint8List.fromList(ZipEncoder().encode(archive));
}
