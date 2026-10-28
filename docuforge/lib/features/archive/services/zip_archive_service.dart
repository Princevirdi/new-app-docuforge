import 'dart:typed_data';

import 'package:archive/archive.dart';

class ArchiveInputFile {
  const ArchiveInputFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

class ExtractedArchiveFile {
  const ExtractedArchiveFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

class ZipArchiveService {
  const ZipArchiveService();

  static const _maxFiles = 500;
  static const _maxUncompressedBytes = 512 * 1024 * 1024;

  Uint8List createZip(List<ArchiveInputFile> files) {
    if (files.isEmpty) {
      throw const FormatException('Choose at least one file to zip.');
    }
    if (files.length > _maxFiles) {
      throw const FormatException(
        'A ZIP archive can contain at most 500 files.',
      );
    }

    final names = <String>{};
    final archive = Archive();
    var totalBytes = 0;
    for (final file in files) {
      final name = file.name.replaceAll('\\', '/');
      if (!_isSafeArchivePath(name)) {
        throw FormatException('Unsafe file name: ${file.name}');
      }
      if (!names.add(name.toLowerCase())) {
        throw FormatException('Duplicate file name: $name');
      }
      totalBytes += file.bytes.length;
      if (totalBytes > _maxUncompressedBytes) {
        throw const FormatException(
          'The selected files exceed the 512 MB ZIP creation limit.',
        );
      }
      archive.addFile(ArchiveFile.bytes(name, file.bytes));
    }
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  List<ExtractedArchiveFile> extractZip(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const FormatException('The selected ZIP file is empty.');
    }

    final archive = ZipDecoder().decodeBytes(bytes);
    final files = <ExtractedArchiveFile>[];
    final outputNames = <String>{};
    var totalBytes = 0;

    for (final entry in archive.files) {
      if (entry.isDirectory) continue;
      if (entry.isSymbolicLink) {
        throw FormatException(
          'The archive contains a symbolic link that cannot be safely '
          'extracted: ${entry.name}',
        );
      }
      if (!_isSafeArchivePath(entry.name)) {
        throw FormatException(
          'The archive contains an unsafe path and was not extracted: '
          '${entry.name}',
        );
      }

      totalBytes += entry.size;
      if (files.length >= _maxFiles || totalBytes > _maxUncompressedBytes) {
        throw const FormatException(
          'The archive exceeds the extraction limit (500 files or 512 MB).',
        );
      }

      final outputName = _safeOutputName(entry.name);
      if (!outputNames.add(outputName.toLowerCase())) {
        throw FormatException(
          'Multiple archive entries would be saved as "$outputName". '
          'Rename them in the ZIP and try again.',
        );
      }
      files.add(
        ExtractedArchiveFile(
          name: outputName,
          bytes: Uint8List.fromList(entry.content),
        ),
      );
    }

    if (files.isEmpty) {
      throw const FormatException('The ZIP archive contains no files.');
    }
    return List.unmodifiable(files);
  }

  bool _isSafeArchivePath(String archivePath) {
    final path = archivePath.replaceAll('\\', '/');
    if (path.isEmpty || path.startsWith('/')) return false;
    if (RegExp(r'^[a-zA-Z]:').hasMatch(path)) return false;
    return path.split('/').every((part) => part.isNotEmpty && part != '..');
  }

  String _safeOutputName(String archivePath) {
    final path = archivePath.replaceAll('\\', '/');
    final safeName = path
        .split('/')
        .map(
          (part) => part.replaceAll(RegExp(r'[<>:"|?*\x00-\x1F]'), '_').trim(),
        )
        .join('_');
    if (safeName.isEmpty || safeName == '.' || safeName == '..') {
      throw FormatException(
        'The archive contains an invalid file name: $archivePath',
      );
    }
    return safeName;
  }
}
