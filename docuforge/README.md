# DocuForge

DocuForge is a cross-platform Flutter document-tools app. PDF compression,
PDF-to-Word, Word-to-PDF, ZIP creation, and ZIP extraction are implemented.
Processing happens locally on the device; files are not uploaded. The picker,
converters, archiver, and saver are configured for Android, iOS, Linux, macOS,
Windows, and Web.

PDF-to-Word renders each PDF page into a high-resolution image in the DOCX.
This keeps the visible text, scans, charts, and page layout together, but the
page content is not directly editable as Word text.
Word-to-PDF preserves paragraph and table-cell text, but reflows the document
using standard fonts; embedded media is rejected rather than silently omitted.
Non-empty headers and footers are also rejected. Neither converter promises
pixel-perfect or complete layout fidelity.

ZIP creation combines selected files into one archive. ZIP extraction previews
the contained files and saves each separately using the platform save dialog.
Archive paths are flattened into safe output names; symbolic links, unsafe
paths, duplicate output names, and archives over 500 files or 512 MB expanded
size are rejected.

The other shortcuts in the app are planned and are not yet functional.

## Project structure

- `lib/app.dart` configures the app theme and root screen.
- `lib/features/home/` contains the home screen and its UI widgets.
- `lib/features/compression/` contains the PDF compression screen and service.
- `lib/features/archive/` contains ZIP creation and extraction screens and
  service.
- `lib/features/conversion/` contains conversion screens, service, and tool
  metadata.

PDF compression uses Syncfusion Flutter PDF, which requires a Syncfusion
Community or commercial license. Confirm that your organization qualifies for
the Community License or obtain a commercial license before distributing the
app. Rewriting a PDF can invalidate its digital signatures; password-protected
documents may not be supported.

## Run locally

```sh
flutter pub get
flutter run
```

## Validate

```sh
flutter analyze
flutter test
```
