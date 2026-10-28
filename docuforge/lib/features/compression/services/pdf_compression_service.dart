import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

enum PdfCompressionPreset {
  fast,
  balanced,
  maximum;

  PdfCompressionLevel get engineLevel => switch (this) {
    PdfCompressionPreset.fast => PdfCompressionLevel.bestSpeed,
    PdfCompressionPreset.balanced => PdfCompressionLevel.normal,
    PdfCompressionPreset.maximum => PdfCompressionLevel.best,
  };
}

class PdfCompressionResult {
  const PdfCompressionResult({
    required this.outputBytes,
    required this.originalSize,
    required this.compressedSize,
  });

  final Uint8List outputBytes;
  final int originalSize;
  final int compressedSize;

  int get bytesSaved => originalSize - compressedSize;

  bool get isSmaller => compressedSize < originalSize;
}

class PdfCompressionService {
  Future<PdfCompressionResult> compress(
    Uint8List inputBytes, {
    PdfCompressionPreset preset = PdfCompressionPreset.balanced,
  }) async {
    if (!_hasPdfSignature(inputBytes)) {
      throw const FormatException('The selected file is not a valid PDF.');
    }

    final document = PdfDocument(inputBytes: inputBytes);
    try {
      document.compressionLevel = preset.engineLevel;
      final compressedBytes = Uint8List.fromList(await document.save());
      final outputBytes = compressedBytes.length < inputBytes.length
          ? compressedBytes
          : Uint8List.fromList(inputBytes);

      return PdfCompressionResult(
        outputBytes: outputBytes,
        originalSize: inputBytes.length,
        compressedSize: outputBytes.length,
      );
    } finally {
      document.dispose();
    }
  }

  bool _hasPdfSignature(Uint8List bytes) {
    const signature = '%PDF-';
    for (
      var offset = 0;
      offset <= 1024 && offset + signature.length <= bytes.length;
      offset++
    ) {
      var matches = true;
      for (var index = 0; index < signature.length; index++) {
        if (bytes[offset + index] != signature.codeUnitAt(index)) {
          matches = false;
          break;
        }
      }
      if (matches) return true;
    }
    return false;
  }
}
