// lib/services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';

// This service class encapsulates all interactions with the Google Gemini API.
// It helps in keeping the API logic separate from the UI code, making the
// application more modular and easier to maintain.

class GeminiService {
  // --- IMPORTANT: API KEY MANAGEMENT ---
  // NEVER hardcode your API key directly in client-side code for production apps.
  // For development, you can temporarily place it here.
  // For production, consider:
  // 1. A backend proxy server that holds the key and makes requests to Gemini.
  // 2. Firebase Remote Config (with strict security rules).
  // 3. Environment variables injected during the build process.
  static const String _apiKey = "AIzaSyASi7Om5giA9QW7LwYWMt2c7ZpR2RTE0Fc"; // REPLACE WITH YOUR ACTUAL KEY

  // The GenerativeModel instance configured for 'gemini-pro'.
  // This model is suitable for a wide range of text generation tasks.
  final GenerativeModel _model;

  // Constructor initializes the GenerativeModel.
  // If the API key is not set, it throws an error.
  GeminiService()
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash', // Updated model name
          apiKey: _apiKey,
          // Optional: Configure safety settings and generation parameters
          // safetySettings: [
          //   SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          // ],
          // generationConfig: GenerationConfig(maxOutputTokens: 200),
        ) {
    if (_apiKey == "YOUR_GEMINI_API_KEY") {
      // This error is a reminder to replace the placeholder API key.
      throw Exception(
          "API Key not set in GeminiService. Please replace 'YOUR_GEMINI_API_KEY'.");
    }
  }

  // Generates a story based on the detected object label and a desired emotion.
  //
  // @param objectLabel The label of the object detected (e.g., "Old Lamp").
  // @param desiredEmotion A hint for the emotional tone of the story (e.g., "Nostalgic").
  // @return A Future<String> containing the generated story, or an error message.
  Future<String> generateStory(
      String objectLabel, String desiredEmotion) async {
    try {
      // Crafting a prompt for the Gemini API to generate a story.
      // The prompt guides the AI to create content that fits the app's context.
      final prompt =
          "Write a short, imaginative, and heartwarming story (around 100-150 words) about an object: '$objectLabel'. "
          "The story should evoke a feeling of '$desiredEmotion'. "
          "The object is the main character or central theme. Make it feel like a hidden tale is being uncovered.";

      // Sending the content to the Gemini API.
      final response = await _model.generateContent([Content.text(prompt)]);

      // Returning the generated text or a default message if no text is found.
      return response.text ?? "Could not generate a story at this time.";
    } catch (e) {
      // Logging the error and returning a user-friendly error message.
      print("Error generating story from Gemini: $e");
      return "Failed to create a story. Please check your connection or API key.";
    }
  }

  // Generates reusable ideas for a given object label.
  //
  // @param objectLabel The label of the object for which to generate ideas (e.g., "Plastic Bottle").
  // @return A Future<List<Map<String, String>>> containing a list of ideas,
  //         where each idea is a map with "title" and "description".
  //         Returns an empty list or list with an error message on failure.
  Future<List<Map<String, String>>> generateReusableIdeas(
      String objectLabel) async {
    try {
      // Crafting a prompt for generating creative reuse ideas.
      // Asking for a specific format can help in parsing the response.
      final prompt =
          "Suggest 3 creative and practical reusable ideas for an item: '$objectLabel'. "
          "For each idea, provide a short title and a brief description. "
          "Format each idea as: Title: [Idea Title] Description: [Idea Description]";

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null || text.isEmpty) {
        return [
          {
            "title": "No ideas found",
            "description": "Could not generate ideas at this time."
          }
        ];
      }

      // Basic parsing of the response.
      // This assumes Gemini returns ideas in the format "Title: ... Description: ..."
      // More robust parsing might be needed based on actual API output.
      final List<Map<String, String>> ideas = [];
      final lines = text.split('\n');
      String currentTitle = "";
      for (var line in lines) {
        if (line.startsWith("Title:")) {
          currentTitle = line.substring("Title:".length).trim();
        } else if (line.startsWith("Description:") && currentTitle.isNotEmpty) {
          ideas.add({
            "title": currentTitle,
            "description": line.substring("Description:".length).trim()
          });
          currentTitle = ""; // Reset for the next idea
        }
      }
       // If parsing fails to find structured ideas, return the raw text as one idea.
      if (ideas.isEmpty && text.isNotEmpty) {
        ideas.add({"title": "Creative Idea for $objectLabel", "description": text});
      }


      return ideas.isNotEmpty ? ideas : [{"title": "Ideas not formatted as expected", "description": text}];
    } catch (e) {
      print("Error generating reusable ideas from Gemini: $e");
      return [
        {
          "title": "Error",
          "description": "Failed to get reusable ideas. Please check connection or API key."
        }
      ];
    }
  }
}
