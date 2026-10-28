import 'package:flutter/material.dart';

import '../models/conversion_operation.dart';
import '../models/operation_category.dart';

const moreOperationCategories = <OperationCategory>[
  OperationCategory(
    title: 'PDF',
    icon: Icons.picture_as_pdf_rounded,
    color: Color(0xFFE45D6D),
    tools: [
      ConversionOperation(
        title: 'PDF to Word',
        icon: Icons.description_rounded,
        color: Color(0xFF4778E8),
      ),
      ConversionOperation(
        title: 'PDF to Excel',
        icon: Icons.table_chart_rounded,
        color: Color(0xFF42A878),
      ),
      ConversionOperation(
        title: 'PDF to PowerPoint',
        icon: Icons.slideshow_rounded,
        color: Color(0xFFE99445),
      ),
      ConversionOperation(
        title: 'PDF to Images',
        icon: Icons.photo_library_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'Images to PDF',
        icon: Icons.collections_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'Compress PDF',
        icon: Icons.compress_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'Merge PDFs',
        icon: Icons.merge_type_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'Split PDF',
        icon: Icons.call_split_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'Extract PDF pages',
        icon: Icons.content_cut_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'Reorder PDF pages',
        icon: Icons.reorder_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'Rotate PDF pages',
        icon: Icons.rotate_right_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'Delete PDF pages',
        icon: Icons.delete_sweep_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'Add PDF watermark',
        icon: Icons.branding_watermark_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'PDF password tools',
        icon: Icons.lock_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'PDF to Text',
        icon: Icons.text_snippet_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'OCR scanned PDF',
        icon: Icons.document_scanner_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'PDF to HTML',
        icon: Icons.language_rounded,
        color: Color(0xFF3DA99A),
      ),
    ],
  ),
  OperationCategory(
    title: 'Word / DOCX',
    icon: Icons.description_rounded,
    color: Color(0xFF4778E8),
    tools: [
      ConversionOperation(
        title: 'Word to PDF',
        icon: Icons.picture_as_pdf_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'DOCX to Text',
        icon: Icons.text_snippet_rounded,
        color: Color(0xFF4778E8),
      ),
      ConversionOperation(
        title: 'DOCX to HTML',
        icon: Icons.language_rounded,
        color: Color(0xFF3DA99A),
      ),
      ConversionOperation(
        title: 'DOCX to Images',
        icon: Icons.image_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'Compress document',
        icon: Icons.compress_rounded,
        color: Color(0xFF4778E8),
      ),
      ConversionOperation(
        title: 'Extract document text',
        icon: Icons.notes_rounded,
        color: Color(0xFF4778E8),
      ),
      ConversionOperation(
        title: 'Merge documents',
        icon: Icons.merge_type_rounded,
        color: Color(0xFF4778E8),
      ),
      ConversionOperation(
        title: 'Split document',
        icon: Icons.call_split_rounded,
        color: Color(0xFF4778E8),
      ),
      ConversionOperation(
        title: 'Remove document metadata',
        icon: Icons.cleaning_services_rounded,
        color: Color(0xFF4778E8),
      ),
    ],
  ),
  OperationCategory(
    title: 'Excel / XLSX',
    icon: Icons.table_chart_rounded,
    color: Color(0xFF42A878),
    tools: [
      ConversionOperation(
        title: 'Excel to PDF',
        icon: Icons.picture_as_pdf_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'XLSX to CSV',
        icon: Icons.grid_on_rounded,
        color: Color(0xFF42A878),
      ),
      ConversionOperation(
        title: 'XLSX to Text',
        icon: Icons.text_snippet_rounded,
        color: Color(0xFF42A878),
      ),
      ConversionOperation(
        title: 'CSV to XLSX',
        icon: Icons.table_view_rounded,
        color: Color(0xFF42A878),
      ),
      ConversionOperation(
        title: 'Compress spreadsheet',
        icon: Icons.compress_rounded,
        color: Color(0xFF42A878),
      ),
      ConversionOperation(
        title: 'Merge spreadsheets',
        icon: Icons.merge_type_rounded,
        color: Color(0xFF42A878),
      ),
      ConversionOperation(
        title: 'Split spreadsheet',
        icon: Icons.call_split_rounded,
        color: Color(0xFF42A878),
      ),
      ConversionOperation(
        title: 'Extract sheets',
        icon: Icons.file_copy_rounded,
        color: Color(0xFF42A878),
      ),
    ],
  ),
  OperationCategory(
    title: 'PowerPoint / PPTX',
    icon: Icons.slideshow_rounded,
    color: Color(0xFFE99445),
    tools: [
      ConversionOperation(
        title: 'PowerPoint to PDF',
        icon: Icons.picture_as_pdf_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'PowerPoint to Images',
        icon: Icons.photo_library_rounded,
        color: Color(0xFFE99445),
      ),
      ConversionOperation(
        title: 'PowerPoint to Text',
        icon: Icons.text_snippet_rounded,
        color: Color(0xFFE99445),
      ),
      ConversionOperation(
        title: 'Compress presentation',
        icon: Icons.compress_rounded,
        color: Color(0xFFE99445),
      ),
      ConversionOperation(
        title: 'Merge presentations',
        icon: Icons.merge_type_rounded,
        color: Color(0xFFE99445),
      ),
      ConversionOperation(
        title: 'Split presentation',
        icon: Icons.call_split_rounded,
        color: Color(0xFFE99445),
      ),
    ],
  ),
  OperationCategory(
    title: 'Images',
    icon: Icons.image_rounded,
    color: Color(0xFFBA6BC8),
    tools: [
      ConversionOperation(
        title: 'JPG to PNG',
        icon: Icons.image_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'PNG to JPG',
        icon: Icons.image_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'Image to WebP',
        icon: Icons.image_search_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'WebP to JPG or PNG',
        icon: Icons.image_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'Compress image',
        icon: Icons.compress_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'Resize image',
        icon: Icons.photo_size_select_large_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'Crop image',
        icon: Icons.crop_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'Rotate image',
        icon: Icons.rotate_right_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'Flip image',
        icon: Icons.flip_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'Change image quality',
        icon: Icons.tune_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'Change image DPI',
        icon: Icons.high_quality_rounded,
        color: Color(0xFFBA6BC8),
      ),
      ConversionOperation(
        title: 'JPG or PNG to PDF',
        icon: Icons.picture_as_pdf_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'Remove image metadata',
        icon: Icons.cleaning_services_rounded,
        color: Color(0xFFBA6BC8),
      ),
    ],
  ),
  OperationCategory(
    title: 'General file tools',
    icon: Icons.folder_copy_rounded,
    color: Color(0xFF536DFE),
    tools: [
      ConversionOperation(
        title: 'Convert file',
        icon: Icons.transform_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Compress file',
        icon: Icons.compress_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Zip files',
        icon: Icons.folder_zip_outlined,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Unzip files',
        icon: Icons.folder_open_outlined,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Merge files',
        icon: Icons.merge_type_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Split file',
        icon: Icons.call_split_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Extract content',
        icon: Icons.output_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Rename file',
        icon: Icons.drive_file_rename_outline_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Copy file',
        icon: Icons.file_copy_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Move file',
        icon: Icons.drive_file_move_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Delete file',
        icon: Icons.delete_outline_rounded,
        color: Color(0xFFE45D6D),
      ),
      ConversionOperation(
        title: 'Encrypt file',
        icon: Icons.lock_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Password protect file',
        icon: Icons.password_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Remove password',
        icon: Icons.no_encryption_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Decrypt file',
        icon: Icons.lock_open_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'View file metadata',
        icon: Icons.info_outline_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Remove file metadata',
        icon: Icons.cleaning_services_rounded,
        color: Color(0xFF536DFE),
      ),
      ConversionOperation(
        title: 'Text to HTML',
        icon: Icons.language_rounded,
        color: Color(0xFF3DA99A),
      ),
      ConversionOperation(
        title: 'CSV to HTML',
        icon: Icons.table_chart_rounded,
        color: Color(0xFF42A878),
      ),
      ConversionOperation(
        title: 'HTML to Text',
        icon: Icons.text_snippet_rounded,
        color: Color(0xFF3DA99A),
      ),
    ],
  ),
];
