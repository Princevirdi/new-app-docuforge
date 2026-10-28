import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newdocuforge/features/archive/services/zip_archive_service.dart';

void main() {
  const service = ZipArchiveService();

  test('creates an archive and extracts original names and bytes', () {
    final inputs = [
      ArchiveInputFile(
        name: 'notes.txt',
        bytes: Uint8List.fromList(utf8.encode('Hello ZIP')),
      ),
      ArchiveInputFile(
        name: 'photo.bin',
        bytes: Uint8List.fromList([0, 1, 2, 255]),
      ),
      ArchiveInputFile(name: 'empty.txt', bytes: Uint8List(0)),
    ];

    final zip = service.createZip(inputs);
    final extracted = service.extractZip(zip);

    expect(extracted.map((file) => file.name), [
      'notes.txt',
      'photo.bin',
      'empty.txt',
    ]);
    expect(extracted.first.bytes, utf8.encode('Hello ZIP'));
    expect(extracted[1].bytes, [0, 1, 2, 255]);
    expect(extracted[2].bytes, isEmpty);
  });

  test('flattens directories into safe output names', () {
    final archive = Archive()
      ..addFile(ArchiveFile.string('reports/annual.txt', 'Annual report'));

    final extracted = service.extractZip(
      Uint8List.fromList(ZipEncoder().encode(archive)),
    );

    expect(extracted.single.name, 'reports_annual.txt');
    expect(utf8.decode(extracted.single.bytes), 'Annual report');
  });

  test('rejects duplicate names and unsafe names when creating archives', () {
    expect(
      () => service.createZip([
        ArchiveInputFile(name: 'file.txt', bytes: Uint8List.fromList([1])),
        ArchiveInputFile(name: 'FILE.txt', bytes: Uint8List.fromList([2])),
      ]),
      throwsFormatException,
    );
    expect(
      () => service.createZip([
        ArchiveInputFile(
          name: '../outside.txt',
          bytes: Uint8List.fromList([1]),
        ),
      ]),
      throwsFormatException,
    );
  });

  test(
    'rejects traversal paths and duplicate flattened names on extraction',
    () {
      final traversalArchive = Archive()
        ..addFile(ArchiveFile.string('../outside.txt', 'unsafe'));
      expect(
        () => service.extractZip(
          Uint8List.fromList(ZipEncoder().encode(traversalArchive)),
        ),
        throwsFormatException,
      );

      final duplicateArchive = Archive()
        ..addFile(ArchiveFile.string('one/report.txt', 'first'))
        ..addFile(ArchiveFile.string('one_report.txt', 'second'));
      expect(
        () => service.extractZip(
          Uint8List.fromList(ZipEncoder().encode(duplicateArchive)),
        ),
        throwsFormatException,
      );
    },
  );

  test('rejects invalid and empty archives', () {
    expect(
      () => service.extractZip(Uint8List.fromList('not zip'.codeUnits)),
      throwsFormatException,
    );
    expect(() => service.extractZip(Uint8List(0)), throwsFormatException);
    expect(() => service.createZip([]), throwsFormatException);
  });
}
