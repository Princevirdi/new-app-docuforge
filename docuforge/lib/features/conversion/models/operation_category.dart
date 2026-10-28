import 'package:flutter/material.dart';

import 'tool_shortcut.dart';

class OperationCategory {
  const OperationCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.tools,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<ToolShortcut> tools;
}
