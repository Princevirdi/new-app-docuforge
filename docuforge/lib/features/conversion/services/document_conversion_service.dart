import 'dart:convert';
import 'dart:ui' show Rect;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:image/image.dart' as image;
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

class DocumentConversionService {
  Future<Uint8List> pdfToDocx(Uint8List inputBytes) async {
    if (!_hasPdfSignature(inputBytes)) {
      throw const FormatException('The selected file is not a valid PDF.');
    }

    await pdfrx.pdfrxFlutterInitialize();
    final document = await pdfrx.PdfDocument.openData(
      inputBytes,
      sourceName: 'docuforge-conversion-${inputBytes.length}',
    );
    try {
      if (document.pages.isEmpty) {
        throw const FormatException('The PDF does not contain any pages.');
      }

      final archive = Archive()
        ..addFile(
          ArchiveFile.string(
            '[Content_Types].xml',
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
                '<Types xmlns="http://schemas.openxmlformats.org/package/2006/'
                'content-types">'
                '<Default Extension="rels" ContentType="application/vnd.'
                'openxmlformats-package.relationships+xml"/>'
                '<Default Extension="xml" ContentType="application/xml"/>'
                '<Default Extension="png" ContentType="image/png"/>'
                '<Override PartName="/word/document.xml" ContentType="'
                'application/vnd.openxmlformats-officedocument.wordprocessingml.'
                'document.main+xml"/>'
                '</Types>',
          ),
        )
        ..addFile(
          ArchiveFile.string(
            '_rels/.rels',
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
                '<Relationships xmlns="http://schemas.openxmlformats.org/'
                'package/2006/relationships">'
                '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/'
                'officeDocument/2006/relationships/officeDocument" '
                'Target="word/document.xml"/>'
                '</Relationships>',
          ),
        );

      final pageXml = <String>[];
      final relationships = <String>[];
      for (var index = 0; index < document.pages.length; index++) {
        final page = document.pages[index];
        final pixelSize = _renderSize(page.width, page.height);
        final renderedPage = await page.render(
          fullWidth: pixelSize.width.toDouble(),
          fullHeight: pixelSize.height.toDouble(),
          backgroundColor: 0xFFFFFFFF,
        );
        if (renderedPage == null) {
          throw StateError('Could not render PDF page ${index + 1}.');
        }

        try {
          final raster = image.Image.fromBytes(
            width: renderedPage.width,
            height: renderedPage.height,
            bytes: renderedPage.pixels.buffer,
            bytesOffset: renderedPage.pixels.offsetInBytes,
            numChannels: 4,
            order: image.ChannelOrder.bgra,
          );
          final pngBytes = image.encodePng(raster);
          final mediaName = 'page_${index + 1}.png';
          final relationshipId = 'rId${index + 1}';
          archive.addFile(ArchiveFile.bytes('word/media/$mediaName', pngBytes));
          relationships.add(
            '<Relationship Id="$relationshipId" '
            'Type="http://schemas.openxmlformats.org/officeDocument/2006/'
            'relationships/image" Target="media/$mediaName"/>',
          );
          if (index > 0) {
            pageXml.add('<w:p><w:r><w:br w:type="page"/></w:r></w:p>');
          }
          pageXml.add(
            _pageImageParagraph(
              relationshipId: relationshipId,
              pageNumber: index + 1,
              pageWidth: page.width,
              pageHeight: page.height,
            ),
          );
        } finally {
          renderedPage.dispose();
        }
      }

      archive.addFile(
        ArchiveFile.string(
          'word/_rels/document.xml.rels',
          '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
              '<Relationships xmlns="http://schemas.openxmlformats.org/'
              'package/2006/relationships">${relationships.join()}'
              '</Relationships>',
        ),
      );
      archive.addFile(
        ArchiveFile.string(
          'word/document.xml',
          '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
              '<w:document xmlns:w="http://schemas.openxmlformats.org/'
              'wordprocessingml/2006/main" '
              'xmlns:r="http://schemas.openxmlformats.org/officeDocument/'
              '2006/relationships" '
              'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/'
              'wordprocessingDrawing" '
              'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/'
              'main" xmlns:pic="http://schemas.openxmlformats.org/'
              'drawingml/2006/picture">'
              '<w:body>${pageXml.join()}'
              '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/>'
              '<w:pgMar w:top="720" w:right="720" w:bottom="720" '
              'w:left="720"/></w:sectPr>'
              '</w:body></w:document>',
        ),
      );

      return Uint8List.fromList(ZipEncoder().encode(archive));
    } finally {
      await document.dispose();
    }
  }

  ({int width, int height}) _renderSize(double pageWidth, double pageHeight) {
    const renderDpi = 200.0;
    const maxPixels = 4000.0;
    final scale = renderDpi / 72;
    final limitScale =
        maxPixels / (pageWidth > pageHeight ? pageWidth : pageHeight);
    final renderScale = scale < limitScale ? scale : limitScale;
    return (
      width: (pageWidth * renderScale).round().clamp(1, maxPixels.toInt()),
      height: (pageHeight * renderScale).round().clamp(1, maxPixels.toInt()),
    );
  }

  String _pageImageParagraph({
    required String relationshipId,
    required int pageNumber,
    required double pageWidth,
    required double pageHeight,
  }) {
    const maxWidthEmu = 6858000.0;
    const maxHeightEmu = 8046720.0;
    const emuPerPoint = 12700.0;
    final scale = (maxWidthEmu / (pageWidth * emuPerPoint)).clamp(
      0.0,
      maxHeightEmu / (pageHeight * emuPerPoint),
    );
    final widthEmu = (pageWidth * emuPerPoint * scale).round();
    final heightEmu = (pageHeight * emuPerPoint * scale).round();

    return '<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:drawing>'
        '<wp:inline distT="0" distB="0" distL="0" distR="0">'
        '<wp:extent cx="$widthEmu" cy="$heightEmu"/>'
        '<wp:docPr id="$pageNumber" name="PDF page $pageNumber" '
        'descr="Rendered image of PDF page $pageNumber"/>'
        '<wp:cNvGraphicFramePr><a:graphicFrameLocks noChangeAspect="1"/>'
        '</wp:cNvGraphicFramePr><a:graphic><a:graphicData '
        'uri="http://schemas.openxmlformats.org/drawingml/2006/picture">'
        '<pic:pic><pic:nvPicPr><pic:cNvPr id="$pageNumber" '
        'name="page_$pageNumber.png"/><pic:cNvPicPr/></pic:nvPicPr>'
        '<pic:blipFill><a:blip r:embed="$relationshipId"/>'
        '<a:stretch><a:fillRect/></a:stretch></pic:blipFill>'
        '<pic:spPr><a:xfrm><a:off x="0" y="0"/>'
        '<a:ext cx="$widthEmu" cy="$heightEmu"/></a:xfrm>'
        '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>'
        '</pic:pic></a:graphicData></a:graphic></wp:inline>'
        '</w:drawing></w:r></w:p>';
  }

  Uint8List docxToPdf(Uint8List inputBytes) {
    final archive = ZipDecoder().decodeBytes(inputBytes);
    final documentXmlFile = archive.findFile('word/document.xml');
    if (documentXmlFile == null) {
      throw const FormatException('The selected file is not a valid DOCX.');
    }

    final xmlText = utf8.decode(documentXmlFile.content, allowMalformed: false);
    final xmlDocument = XmlDocument.parse(xmlText);
    final body = _findElement(xmlDocument.rootElement, 'body');
    if (body == null) {
      throw const FormatException('The DOCX document body is missing.');
    }
    _rejectUnsupportedWordContent(xmlDocument, archive);

    final blocks = <String>[];
    _appendBodyBlocks(body, blocks);
    if (blocks.every((block) => block.trim().isEmpty)) {
      throw const FormatException('No readable text was found in the DOCX.');
    }

    final pdf = PdfDocument();
    try {
      var page = pdf.pages.add();
      var y = 40.0;
      final font = PdfStandardFont(PdfFontFamily.helvetica, 11);
      final pageWidth = page.getClientSize().width;
      const horizontalMargin = 40.0;
      const bottomMargin = 40.0;

      for (final block in blocks) {
        if (block.isEmpty) {
          y += 14;
          continue;
        }
        if (y > page.getClientSize().height - bottomMargin) {
          page = pdf.pages.add();
          y = 40;
        }
        final result = PdfTextElement(text: block, font: font).draw(
          page: page,
          bounds: Rect.fromLTWH(
            horizontalMargin,
            y,
            pageWidth - horizontalMargin * 2,
            page.getClientSize().height - y - bottomMargin,
          ),
          format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
        );
        if (result == null) {
          throw StateError('Could not lay out a paragraph in the output PDF.');
        }
        page = result.page;
        y = result.bounds.bottom + 8;
      }

      return Uint8List.fromList(pdf.saveSync());
    } finally {
      pdf.dispose();
    }
  }

  void _appendBodyBlocks(XmlElement parent, List<String> blocks) {
    for (final child in parent.children.whereType<XmlElement>()) {
      switch (child.name.local) {
        case 'p':
          blocks.add(_paragraphText(child));
        case 'tbl':
          for (final row in child.childElements.where(
            (element) => element.name.local == 'tr',
          )) {
            final cells = row.childElements
                .where((element) => element.name.local == 'tc')
                .map(_tableCellText)
                .toList();
            if (cells.isNotEmpty) blocks.add(cells.join('  |  '));
          }
        default:
          _appendBodyBlocks(child, blocks);
      }
    }
  }

  String _tableCellText(XmlElement cell) {
    final paragraphs = <String>[];
    void collect(XmlElement element) {
      for (final child in element.childElements) {
        if (child.name.local == 'p') {
          final text = _paragraphText(child);
          if (text.isNotEmpty) paragraphs.add(text);
        } else {
          collect(child);
        }
      }
    }

    collect(cell);
    return paragraphs.join('\n');
  }

  String _paragraphText(XmlElement paragraph) {
    final result = StringBuffer();
    void append(XmlElement element) {
      for (final child in element.children) {
        if (child is XmlElement) {
          switch (child.name.local) {
            case 't':
              result.write(child.innerText);
            case 'tab':
              result.write('\t');
            case 'br':
              result.write('\n');
            case 'del':
            case 'delText':
              break;
            default:
              append(child);
          }
        }
      }
    }

    append(paragraph);
    return result.toString();
  }

  void _rejectUnsupportedWordContent(XmlDocument document, Archive archive) {
    final root = document.rootElement;
    const unsupportedElements = {
      'drawing',
      'pict',
      'object',
      'footnoteReference',
      'endnoteReference',
      'commentRangeStart',
      'commentReference',
    };
    for (final element in root.descendants.whereType<XmlElement>()) {
      if (unsupportedElements.contains(element.name.local)) {
        throw const FormatException(
          'This DOCX contains images, drawings, notes, or comments that this '
          'text-based converter cannot preserve. The original was not changed.',
        );
      }
    }

    final mediaFile = archive.files.any(
      (file) =>
          file.isFile &&
          (file.name.startsWith('word/media/') ||
              file.name.startsWith('word/charts/') ||
              file.name.startsWith('word/embeddings/') ||
              file.name.startsWith('word/diagrams/')),
    );
    if (mediaFile) {
      throw const FormatException(
        'This DOCX contains embedded media or objects that this text-based '
        'converter cannot preserve. The original was not changed.',
      );
    }

    final nonEmptyHeaderOrFooter = archive.files
        .where(
          (file) =>
              file.isFile &&
              (RegExp(r'^word/header\d*\.xml$').hasMatch(file.name) ||
                  RegExp(r'^word/footer\d*\.xml$').hasMatch(file.name)),
        )
        .any((file) {
          final xml = XmlDocument.parse(
            utf8.decode(file.content, allowMalformed: false),
          );
          return xml.rootElement.descendants.whereType<XmlElement>().any(
            (element) =>
                element.name.local == 't' &&
                element.innerText.trim().isNotEmpty,
          );
        });
    if (nonEmptyHeaderOrFooter) {
      throw const FormatException(
        'This DOCX contains header or footer text that this converter cannot '
        'preserve. The original was not changed.',
      );
    }
  }

  XmlElement? _findElement(XmlElement root, String localName) {
    if (root.name.local == localName) return root;
    for (final child in root.childElements) {
      final found = _findElement(child, localName);
      if (found != null) return found;
    }
    return null;
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
