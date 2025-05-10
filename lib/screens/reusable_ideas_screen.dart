import 'package:emotivision/services/gemini_service.dart';
import 'package:emotivision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

// lib/screens/reusable_ideas_screen.dart
// This screen fetches and displays reusable ideas for a given object
// from the Gemini API.

class ReusableIdeasScreen extends StatefulWidget {
  final String objectLabel;

  const ReusableIdeasScreen({super.key, required this.objectLabel});

  @override
  State<ReusableIdeasScreen> createState() => _ReusableIdeasScreenState();
}

class _ReusableIdeasScreenState extends State<ReusableIdeasScreen> with SingleTickerProviderStateMixin {
  late final GeminiService _geminiService;
  Future<List<Map<String, String>>>? _ideasFuture;
  late AnimationController _controller;
  late Animation<double> _cardAnim;
  late Animation<double> _buttonAnim;

  // List of fallback icons for ideas.
  final List<IconData> _ideaIcons = [
    Icons.lightbulb_outline_sharp,
    Icons.eco_outlined,
    Icons.build_circle_outlined,
    Icons.star_outline_sharp,
    Icons.extension_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _buttonAnim = CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack));
    // Initialize GeminiService and fetch ideas.
    try {
      _geminiService = GeminiService();
      _ideasFuture = _geminiService.generateReusableIdeas(widget.objectLabel);
    } catch (e) {
      print("Failed to initialize GeminiService for ideas: $e");
      _ideasFuture = Future.value([
        {
          "title": "Service Error",
          "description": "Could not connect to AI service: \\${e.toString()}"
        }
      ]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: Could not connect to AI service. \\${e.toString()}"),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      });
    }
    _controller.forward();
  }

  IconData _getIconForIdea(int index) {
    return _ideaIcons[index % _ideaIcons.length];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F6FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/sparkle.json',
                  height: 100,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  "Step 3: Let's ",
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    color: Colors.grey[700],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                    children: const [
                      TextSpan(text: 'Reimagine ', style: TextStyle(color: Color(0xFF3DDC97))),
                      TextSpan(text: 'its Purpose with Magic!'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '✨ Amazing Reuse Ideas for the "${widget.objectLabel}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 32,
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ScaleTransition(
                  scale: _cardAnim,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withOpacity(0.13),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: AppColors.primaryOrange.withOpacity(0.18), width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.autorenew, color: AppColors.primaryOrange, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              'New Life for the "${widget.objectLabel}" !',
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<List<Map<String, String>>>(
                          future: _ideasFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(
                                child: Text(
                                  snapshot.error?.toString() ?? "No ideas found or error fetching ideas.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppColors.errorColor, fontSize: 16),
                                ),
                              );
                            }
                            final ideas = snapshot.data!;
                            if (ideas.first["title"] == "Service Error" || ideas.first["title"] == "Error") {
                              return Center(
                                child: Text(
                                  ideas.first["description"] ?? "An unknown error occurred.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppColors.errorColor, fontSize: 16),
                                ),
                              );
                            }
                            return Column(
                              children: [
                                ...ideas.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final idea = entry.value;
                                  return AnimatedPadding(
                                    duration: Duration(milliseconds: 300 + index * 100),
                                    curve: Curves.easeOutBack,
                                    padding: EdgeInsets.only(top: index == 0 ? 0 : 16),
                                    child: Material(
                                      color: const Color(0xFFF2FAFF),
                                      borderRadius: BorderRadius.circular(18),
                                      elevation: 2,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.primaryOrange.withOpacity(0.15),
                                          child: Icon(
                                            _getIconForIdea(index),
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                        title: Text(
                                          idea["title"] ?? "Untitled Idea",
                                          style: GoogleFonts.fredoka(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryOrange,
                                            fontSize: 18,
                                          ),
                                        ),
                                        subtitle: Text(
                                          idea["description"] ?? "No description available.",
                                          style: GoogleFonts.comicNeue(
                                            color: AppColors.secondaryText,
                                            fontSize: 16,
                                            height: 1.4,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ScaleTransition(
                  scale: _buttonAnim,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.primaryOrange.withOpacity(0.3),
                    ),
                    child: Text(
                      'Start a New Adventure!  ↻',
                      style: GoogleFonts.fredoka(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
