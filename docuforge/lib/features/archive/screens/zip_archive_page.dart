import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/zip_archive_service.dart';

enum ZipArchiveOperation { create, extract }

void openZipArchivePage(BuildContext context, ZipArchiveOperation operation) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ZipArchivePage(operation: operation),
    ),
  );
}

class ZipArchivePage extends StatefulWidget {
  const ZipArchivePage({required this.operation, super.key});

  final ZipArchiveOperation operation;

  @override
  State<ZipArchivePage> createState() => _ZipArchivePageState();
}

class _ZipArchivePageState extends State<ZipArchivePage> {
  final _service = ZipArchiveService();
  final _archiveNameController = TextEditingController(text: 'archive');
  List<ArchiveInputFile> _selectedFiles = [];
  List<ExtractedArchiveFile> _extractedFiles = [];
  bool _isBusy = false;
  String? _errorMessage;
  String? _statusMessage;

  bool get _isCreating => widget.operation == ZipArchiveOperation.create;

  @override
  void dispose() {
    _archiveNameController.dispose();
    super.dispose();
  }

  Future<void> _selectFilesToZip() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _statusMessage = null;
      _selectedFiles = [];
    });
    try {
      final selection = await FilePicker.pickFiles();
      if (selection.isEmpty) return;
      final files = <ArchiveInputFile>[];
      for (final file in selection) {
        final bytes = await file.readAsBytes();
        files.add(ArchiveInputFile(name: file.name, bytes: bytes));
      }
      if (!mounted) return;
      setState(() => _selectedFiles = files);
    } catch (error) {
      if (mounted) {
        setState(
          () => _errorMessage = 'Could not read the selected files: $error',
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _createAndSaveZip() async {
    if (_selectedFiles.isEmpty || _isBusy) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      final archiveBytes = _service.createZip(_selectedFiles);
      final archiveName = _archiveNameController.text.trim();
      if (archiveName.isEmpty) {
        throw const FormatException('Enter a name for the ZIP file.');
      }
      final safeName = _safeArchiveName(archiveName);
      final result = await FilePicker.saveFile(
        fileName: '$safeName.zip',
        bytes: archiveBytes,
        mimeType: 'application/zip',
        dialogTitle: 'Save ZIP archive',
      );
      if (!mounted) return;
      setState(() {
        _statusMessage = result == null
            ? 'Save cancelled.'
            : 'ZIP archive saved.';
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _errorMessage = 'Could not create the ZIP archive: $error',
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _selectZipFile() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _statusMessage = null;
      _extractedFiles = [];
    });
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['zip'],
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final files = _service.extractZip(bytes);
      if (!mounted) return;
      setState(() => _extractedFiles = files);
    } catch (error) {
      if (mounted) {
        setState(
          () => _errorMessage = 'Could not open that ZIP archive: $error',
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _saveExtractedFile(ExtractedArchiveFile file) async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      final result = await FilePicker.saveFile(
        fileName: file.name,
        bytes: file.bytes,
        mimeType: 'application/octet-stream',
        dialogTitle: 'Save extracted file',
      );
      if (!mounted) return;
      setState(() {
        _statusMessage = result == null
            ? 'Save cancelled.'
            : 'Saved ${file.name}.';
      });
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not save ${file.name}: $error');
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _saveAllExtractedFiles() async {
    if (_extractedFiles.isEmpty || _isBusy) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _statusMessage = null;
    });
    var savedCount = 0;
    try {
      for (final file in _extractedFiles) {
        final result = await FilePicker.saveFile(
          fileName: file.name,
          bytes: file.bytes,
          mimeType: 'application/octet-stream',
          dialogTitle:
              'Save extracted file ${savedCount + 1} of '
              '${_extractedFiles.length}',
        );
        if (result == null) break;
        savedCount++;
      }
      if (mounted) {
        setState(() {
          _statusMessage = savedCount == _extractedFiles.length
              ? 'Saved all $savedCount files.'
              : 'Saved $savedCount of ${_extractedFiles.length} files. '
                    'Remaining files were not saved.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not save all extracted files: $error';
          if (savedCount > 0) {
            _statusMessage =
                'Saved $savedCount of ${_extractedFiles.length} files before '
                'the error.';
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isCreating ? 'Zip files' : 'Unzip files';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _isCreating ? 'Create a ZIP archive' : 'Extract a ZIP archive',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Files are handled on this device. Nothing is uploaded.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (_isCreating) ...[
            OutlinedButton.icon(
              onPressed: _isBusy ? null : _selectFilesToZip,
              icon: const Icon(Icons.add_to_drive_rounded),
              label: Text(
                _selectedFiles.isEmpty
                    ? 'Choose files'
                    : 'Choose files (${_selectedFiles.length})',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                alignment: Alignment.centerLeft,
              ),
            ),
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _archiveNameController,
                enabled: !_isBusy,
                decoration: const InputDecoration(
                  labelText: 'ZIP file name',
                  suffixText: '.zip',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              ..._selectedFiles.map(
                (file) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(_formatSize(file.bytes.length)),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _isBusy ? null : _createAndSaveZip,
                icon: _isBusy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.folder_zip_outlined),
                label: Text(_isBusy ? 'Working...' : 'Create and save ZIP'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ] else ...[
            OutlinedButton.icon(
              onPressed: _isBusy ? null : _selectZipFile,
              icon: const Icon(Icons.folder_open_outlined),
              label: Text(
                _extractedFiles.isEmpty
                    ? 'Choose a ZIP file'
                    : 'Choose another ZIP file',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                alignment: Alignment.centerLeft,
              ),
            ),
            if (_extractedFiles.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                '${_extractedFiles.length} files found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _isBusy ? null : _saveAllExtractedFiles,
                icon: _isBusy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_alt_rounded),
                label: Text(
                  _isBusy ? 'Working...' : 'Save all files individually',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A save dialog opens for each file. Folder paths are flattened '
                'into safe filenames.',
                style: TextStyle(color: Color(0xFF737C92), fontSize: 12),
              ),
              const SizedBox(height: 8),
              ..._extractedFiles.map(
                (file) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(_formatSize(file.bytes.length)),
                  trailing: IconButton(
                    tooltip: 'Save ${file.name}',
                    onPressed: _isBusy ? null : () => _saveExtractedFile(file),
                    icon: const Icon(Icons.save_alt_rounded),
                  ),
                ),
              ),
            ],
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _MessageCard(
              message: _errorMessage!,
              color: const Color(0xFFFFEEEE),
              textColor: const Color(0xFF9D3030),
            ),
          ],
          if (_statusMessage != null) ...[
            const SizedBox(height: 16),
            _MessageCard(
              message: _statusMessage!,
              color: const Color(0xFFEEF0FF),
              textColor: const Color(0xFF394778),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Extraction is limited to 500 files and 512 MB total expanded data. '
            'Unsafe archive paths and symbolic links are rejected.',
            style: TextStyle(color: Color(0xFF737C92), fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _safeArchiveName(String name) {
    final withoutExtension = name.replaceFirst(
      RegExp(r'\.zip$', caseSensitive: false),
      '',
    );
    final safeName = withoutExtension
        .split(RegExp(r'[/\\]'))
        .last
        .replaceAll(RegExp(r'[<>:"|?*\x00-\x1F]'), '_')
        .trim()
        .replaceAll(RegExp(r'[. ]+$'), '');
    if (safeName.isEmpty) {
      throw const FormatException('Enter a valid name for the ZIP file.');
    }
    return safeName;
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
