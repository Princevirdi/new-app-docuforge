import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:newdocuforge/features/compression/services/pdf_compression_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  late PdfCompressionService service;

  setUp(() {
    service = PdfCompressionService();
  });

  test(
    'compresses valid PDF bytes and does not increase output size',
    () async {
      final document = PdfDocument();
      document.pages.add().graphics.drawString(
        'DocuForge compression test',
        PdfStandardFont(PdfFontFamily.helvetica, 16),
      );
      final inputBytes = Uint8List.fromList(await document.save());
      document.dispose();

      final result = await service.compress(
        inputBytes,
        preset: PdfCompressionPreset.maximum,
      );

      expect(result.outputBytes.take(5), '%PDF-'.codeUnits);
      expect(result.originalSize, inputBytes.length);
      expect(result.compressedSize, lessThanOrEqualTo(inputBytes.length));
      expect(result.bytesSaved, greaterThanOrEqualTo(0));
    },
  );

  test('rejects files without a PDF signature', () async {
    await expectLater(
      service.compress(Uint8List.fromList('not a PDF'.codeUnits)),
      throwsFormatException,
    );
  });
}
