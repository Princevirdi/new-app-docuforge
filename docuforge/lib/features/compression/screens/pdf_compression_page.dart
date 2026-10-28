import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import '../services/pdf_compression_service.dart';

void openPdfCompressionPage(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const PdfCompressionPage()));
}

class PdfCompressionPage extends StatefulWidget {
  const PdfCompressionPage({super.key});

  @override
  State<PdfCompressionPage> createState() => _PdfCompressionPageState();
}

class _PdfCompressionPageState extends State<PdfCompressionPage> {
  final _compressionService = PdfCompressionService();
  String? _fileName;
  Uint8List? _inputBytes;
  PdfCompressionPreset _preset = PdfCompressionPreset.balanced;
  PdfCompressionResult? _result;
  bool _isBusy = false;
  String? _errorMessage;

  Future<void> _selectPdf() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final selection = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (selection.isEmpty) return;

      final file = selection.single;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _fileName = file.name;
        _inputBytes = bytes;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not open that PDF: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _compressPdf() async {
    final bytes = _inputBytes;
    if (bytes == null || _isBusy) return;

    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _result = null;
    });
    try {
      final result = await _compressionService.compress(bytes, preset: _preset);
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Compression failed: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _savePdf() async {
    final result = _result;
    final fileName = _fileName;
    if (result == null || fileName == null || _isBusy) return;

    final baseName = fileName.replaceFirst(
      RegExp(r'\.pdf$', caseSensitive: false),
      '',
    );
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    try {
      final savedPath = await FileSaver.instance.saveAs(
        name: '${baseName}_compressed',
        bytes: result.outputBytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
        dialogTitle: 'Save compressed PDF',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedPath == null ? 'Save cancelled.' : 'Compressed PDF saved.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not save the compressed PDF: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Compress PDF')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Make your PDF smaller',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a PDF and compress it on this device. Your file is not '
            'uploaded.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _isBusy ? null : _selectPdf,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(_fileName ?? 'Choose a PDF'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Compression level',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          SegmentedButton<PdfCompressionPreset>(
            segments: const [
              ButtonSegment(
                value: PdfCompressionPreset.fast,
                label: Text('Fast'),
              ),
              ButtonSegment(
                value: PdfCompressionPreset.balanced,
                label: Text('Balanced'),
              ),
              ButtonSegment(
                value: PdfCompressionPreset.maximum,
                label: Text('Maximum'),
              ),
            ],
            selected: {_preset},
            onSelectionChanged: _isBusy
                ? null
                : (selection) {
                    setState(() {
                      _preset = selection.first;
                      _result = null;
                    });
                  },
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _inputBytes == null || _isBusy ? null : _compressPdf,
            icon: _isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.compress_rounded),
            label: Text(_isBusy ? 'Working...' : 'Compress PDF'),
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
          if (result != null) ...[
            const SizedBox(height: 20),
            _MessageCard(
              message: result.isSmaller
                  ? 'Reduced by ${_formatSize(result.bytesSaved)} '
                        '(${_formatPercent(result)}). '
                        '${_formatSize(result.originalSize)} → '
                        '${_formatSize(result.compressedSize)}'
                  : 'Compression did not make this file smaller. The original '
                        'will be kept rather than increasing its size.',
              color: const Color(0xFFEEF0FF),
              textColor: const Color(0xFF394778),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isBusy ? null : _savePdf,
              icon: const Icon(Icons.save_alt_rounded),
              label: const Text('Save compressed PDF'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Note: rewriting a PDF can invalidate its digital signatures. '
            'Password-protected files may not be supported.',
            style: TextStyle(color: Color(0xFF737C92), fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatPercent(PdfCompressionResult result) {
    final percent = result.bytesSaved * 100 / result.originalSize;
    return '${percent.toStringAsFixed(1)}%';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
