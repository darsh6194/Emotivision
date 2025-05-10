import 'package:emotivision/screens/home_screen.dart'; // Corrected import for project name
import 'package:emotivision/utils/app_colors.dart';   // Corrected import for project name
import 'package:flutter/material.dart';

// lib/main.dart
// This is the entry point of the EmotiVision Flutter application.
// It sets up the root MaterialApp widget, defines the theme, and
// specifies the initial screen (HomeScreen).

void main() {
  // Ensures that Flutter's widget binding is initialized before running the app.
  // This is often required for plugins or when specific Flutter features are used early.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Title of the application, used by the operating system.
      title: 'EmotiVision',
      // Theme data for the application, defining default colors, fonts, etc.
      theme: ThemeData(
        // Primary color swatch for the app.
        primarySwatch: Colors.orange, // MaterialColor, influences many default widget colors.
        // Defines the primary color for app bars, buttons, etc.
        primaryColor: AppColors.primaryOrange,
        // Defines the accent color, often used for FABs, active states, etc.
        // In ThemeData, 'colorScheme.secondary' is the modern equivalent of 'accentColor'.
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.orange, // Base for generating color scheme
        ).copyWith(
          secondary: AppColors.primaryGreen, // Accent color
          background: AppColors.primaryBackground, // Default background
        ),
        // Default font family for the application.
        // Ensure this font is included in pubspec.yaml if it's a custom font.
        fontFamily: 'Roboto', // A common and readable sans-serif font.
        // Scaffold background color, applies to the base of most screens.
        scaffoldBackgroundColor: AppColors.primaryBackground,
        // AppBar theme configuration.
        appBarTheme: const AppBarTheme(
          // Default background color for AppBars.
          backgroundColor: Colors.transparent, // Making AppBar transparent by default
          // Default elevation for AppBars.
          elevation: 0,
          // Default icon color in AppBars.
          iconTheme: IconThemeData(color: AppColors.secondaryText),
          // Default title text style in AppBars.
          titleTextStyle: TextStyle(
            color: AppColors.primaryOrange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        // ElevatedButton theme configuration.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen, // Button background color
            foregroundColor: Colors.white, // Button text/icon color
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
        // Card theme configuration.
        cardTheme: CardTheme(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: AppColors.cardBackground,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        ),
      ),
      // The first screen to be displayed when the app starts.
      home: const HomeScreen(),
      // Hides the debug banner in the top-right corner.
      debugShowCheckedModeBanner: false,
    );
  }
}
