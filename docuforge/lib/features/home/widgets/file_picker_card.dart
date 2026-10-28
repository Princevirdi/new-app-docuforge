import 'package:flutter/material.dart';

class FilePickerCard extends StatelessWidget {
  const FilePickerCard({required this.onCompressPdf, super.key});

  final VoidCallback onCompressPdf;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E9F4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A18254B),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.drive_folder_upload_outlined,
              color: Color(0xFF536DFE),
              size: 25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start with PDF compression',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text('Shrink a PDF and save a copy on your device'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCompressPdf,
              icon: const Icon(Icons.compress_rounded),
              label: const Text('Choose a PDF'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
