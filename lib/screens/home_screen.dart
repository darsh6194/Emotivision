import 'package:emotivision/screens/object_detection_screen.dart';
import 'package:emotivision/utils/app_colors.dart';
import 'package:flutter/material.dart';

// lib/screens/home_screen.dart
// This is the landing screen of the EmotiVision app.
// It introduces the app's purpose and provides a button to start exploring.

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design.
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Body of the Scaffold, centered and padded.
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05), // Responsive padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Spacer to push content down a bit.
                const Spacer(flex: 2),

                // App title with icon.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Using a Material Design icon as a placeholder.
                    // Replace 'assets/icons/eye_icon.png' with your actual asset if available.
                    const Icon(
                      Icons.remove_red_eye_outlined, // Placeholder icon
                      color: AppColors.primaryOrange,
                      size: 40,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'EmotiVision',
                      style: TextStyle(
                        fontSize: 42, // Slightly reduced for better fit
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02), // Responsive spacing

                // App tagline.
                const Text(
                  'Unlock the hidden emotions and untold\nstories of the objects that surround you!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText,
                    height: 1.4, // Line height
                  ),
                ),
                SizedBox(height: screenHeight * 0.05), // Responsive spacing

                // "Let's Explore!" button.
                ElevatedButton.icon(
                  // Using a Material Design icon as a placeholder.
                  // Replace 'assets/icons/magic_wand_icon.png' with your actual asset.
                  icon: const Icon(
                    Icons.auto_fix_high, // Placeholder for magic wand
                    color: Colors.white,
                    size: 24,
                  ),
                  label: const Text("Let's Explore!"),
                  onPressed: () {
                    // Navigate to the ObjectDetectionScreen.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ObjectDetectionScreen()),
                    );
                  },
                  // Style is inherited from ThemeData, but can be overridden here if needed.
                ),
                // Spacer to push the bottom text down.
                const Spacer(flex: 3),

                // Footer text.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Using a Material Design icon as a placeholder.
                    // Replace 'assets/icons/sparkle_icon.png' with your actual asset.
                    Icon(
                      Icons.flare_outlined, // Placeholder for sparkle
                      color: AppColors.secondaryText.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Discover. Feel. Reimagine.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.flare_outlined, // Placeholder for sparkle
                      color: AppColors.secondaryText.withOpacity(0.7),
                      size: 20,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02), // Responsive spacing at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
