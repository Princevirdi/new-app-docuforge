import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import '../services/document_conversion_service.dart';

enum DocumentConversionDirection { pdfToWord, wordToPdf }

void openDocumentConversionPage(
  BuildContext context,
  DocumentConversionDirection direction,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DocumentConversionPage(direction: direction),
    ),
  );
}

class DocumentConversionPage extends StatefulWidget {
  const DocumentConversionPage({required this.direction, super.key});

  final DocumentConversionDirection direction;

  @override
  State<DocumentConversionPage> createState() => _DocumentConversionPageState();
}

class _DocumentConversionPageState extends State<DocumentConversionPage> {
  final _conversionService = DocumentConversionService();
  String? _fileName;
  Uint8List? _inputBytes;
  Uint8List? _outputBytes;
  bool _isBusy = false;
  String? _errorMessage;

  bool get _isPdfToWord =>
      widget.direction == DocumentConversionDirection.pdfToWord;

  String get _sourceExtension => _isPdfToWord ? 'pdf' : 'docx';
  String get _targetExtension => _isPdfToWord ? 'docx' : 'pdf';
  String get _title => _isPdfToWord ? 'PDF to Word' : 'Word to PDF';

  Future<void> _selectFile() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _outputBytes = null;
    });

    try {
      final selection = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [_sourceExtension],
      );
      if (selection.isEmpty) return;

      final file = selection.single;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const FormatException('The selected file is empty.');
      }
      if (!mounted) return;
      setState(() {
        _fileName = file.name;
        _inputBytes = bytes;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not open that $_sourceExtension file: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _convert() async {
    final bytes = _inputBytes;
    if (bytes == null || _isBusy) return;

    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _outputBytes = null;
    });
    try {
      final output = _isPdfToWord
          ? await _conversionService.pdfToDocx(bytes)
          : _conversionService.docxToPdf(bytes);
      if (mounted) setState(() => _outputBytes = output);
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Conversion failed: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _save() async {
    final bytes = _outputBytes;
    final fileName = _fileName;
    if (bytes == null || fileName == null || _isBusy) return;

    final baseName = fileName.replaceFirst(
      RegExp('\\.$_sourceExtension\$', caseSensitive: false),
      '',
    );
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    try {
      final savedPath = await FileSaver.instance.saveAs(
        name: '${baseName}_converted',
        bytes: bytes,
        fileExtension: _targetExtension,
        mimeType: _isPdfToWord ? MimeType.microsoftWord : MimeType.pdf,
        dialogTitle: 'Save converted $_targetExtension',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedPath == null ? 'Save cancelled.' : 'Converted file saved.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not save the converted file: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _isPdfToWord
                ? 'Preserve PDF pages in Word'
                : 'Create a PDF from Word',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Files are converted on this device and are not uploaded.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _isBusy ? null : _selectFile,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(
              _fileName ?? 'Choose a ${_sourceExtension.toUpperCase()}',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _inputBytes == null || _isBusy ? null : _convert,
            icon: _isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.transform_rounded),
            label: Text(
              _isBusy ? 'Working...' : 'Convert to $_targetExtension',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _MessageCard(
              message: _errorMessage!,
              color: const Color(0xFFFFEEEE),
              textColor: const Color(0xFF9D3030),
            ),
          ],
          if (_outputBytes != null) ...[
            const SizedBox(height: 16),
            const _MessageCard(
              message: 'Conversion complete. Save a copy to your device.',
              color: Color(0xFFEEF0FF),
              textColor: Color(0xFF394778),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isBusy ? null : _save,
              icon: const Icon(Icons.save_alt_rounded),
              label: Text('Save ${_targetExtension.toUpperCase()}'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            _isPdfToWord
                ? 'Each PDF page is placed into Word as a high-resolution '
                      'image to preserve its visible text, scans, charts, and '
                      'layout. Page content is not directly editable in Word.'
                : 'Text, paragraphs, and basic table cell content are carried '
                      'over. This creates a reflowed PDF; original fonts, '
                      'styling, and exact page layout may differ. Documents '
                      'with embedded media or non-empty headers and footers '
                      'are rejected rather than silently dropping content.',
            style: const TextStyle(color: Color(0xFF737C92), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    required this.color,
    required this.textColor,
  });

  final String message;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message, style: TextStyle(color: textColor)),
    );
  }
}
