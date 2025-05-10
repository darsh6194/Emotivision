import 'package:flutter/material.dart';

// lib/utils/app_colors.dart
// This file defines the primary colors used throughout the EmotiVision application.
// Using a centralized color definition helps in maintaining a consistent UI theme
// and makes it easier to update colors globally if needed.

class AppColors {
  // Primary color for the app theme
  static const Color primaryColor = Color(0xFF69F0AE);  // Same as primaryGreen

  // Accent color for secondary elements
  static const Color accentColor = Color(0xFFFFAB40);  // Same as primaryOrange

  // Primary background color for most screens, a light cyan shade.
  static const Color primaryBackground = Color(0xFFE0F7FA);

  // Accent color, often used for branding elements like titles or important icons.
  // An orange accent color as seen in the provided UI images.
  static const Color primaryOrange = Colors.orangeAccent; // More vibrant: Color(0xFFFFAB40);

  // A slightly darker shade of orange, potentially for text or secondary icons.
  static const Color darkOrange = Color(0xFFF57C00); // Colors.orangeAccent.shade700;

  // Primary color for action buttons, a vibrant green.
  static const Color primaryGreen = Color(0xFF69F0AE); // Colors.greenAccent.shade400;

  // Text color for primary headings or important text.
  static const Color primaryText = Colors.black87;

  // Text color for subtitles, descriptions, or less emphasized text.
  static const Color secondaryText = Colors.black54;

  // Color for card backgrounds or distinct sections.
  static const Color cardBackground = Colors.white;

  // Color for placeholder or disabled elements.
  static const Color placeholderText = Colors.grey;

  // Color for error messages or indicators.
  static const Color errorColor = Colors.redAccent;
}
