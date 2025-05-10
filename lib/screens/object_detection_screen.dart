import 'package:emotivision/screens/story_creation_screen.dart';
import 'package:emotivision/services/camera_service.dart';
import 'package:emotivision/services/cloud_vision_service.dart';
import 'package:emotivision/services/gemini_service.dart';
import 'package:emotivision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// lib/screens/object_detection_screen.dart

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  // Services
  late final GeminiService _geminiService;
  final CameraService _cameraService = CameraService();
  final CloudVisionService _cloudVisionService = CloudVisionService();

  // State variables
  bool _isCameraOn = false;
  String _statusMessage = "Awaiting Your Discovery!";
  String _detectedObjectLabel = "";
  bool _isLoading = false;
  ObjectDetector? _objectDetector;
  bool _isDetecting = false;
  bool _useCloudVision = false; // Toggle between ML Kit and Cloud Vision

  // Custom labels we want to detect
  final Set<String> _targetLabels = {
    'bottle', 'pen', 'book', 'paper', 'cup', 'phone', 'laptop', 
    'keyboard', 'mouse', 'chair', 'table', 'desk', 'backpack', 
    'bag', 'glasses', 'watch', 'headphones', 'notebook'
  };

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize GeminiService
      _geminiService = GeminiService();

      // Initialize camera
      await _cameraService.initialize();

      // Initialize object detector with default model
      final options = ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      );
      
      _objectDetector = ObjectDetector(options: options);
      await _cameraService.controller?.startImageStream(_processCameraImage);
      
      if (mounted) {
        setState(() {
          _isCameraOn = true;
          _statusMessage = "Point at an object and hit Discover!";
        });
      }
    } catch (e) {
      print("Error initializing services: $e"); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;
    
    try {
      if (_useCloudVision) {
        await _processWithCloudVision(image);
      } else {
        await _processWithMLKit(image);
      }
    } catch (e) {
      print("Error processing image: $e");
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _processWithCloudVision(CameraImage image) async {
    try {
      final detections = await _cloudVisionService.detectObjects(image);
      
      if (detections.isNotEmpty) {
        // Filter detections based on target labels
        final validDetections = detections.where((detection) =>
          _targetLabels.contains(detection.label.toLowerCase()) &&
          detection.confidence > 0.7
        ).toList();

        if (validDetections.isNotEmpty) {
          // Get the detection with highest confidence
          final bestDetection = validDetections.reduce((a, b) =>
            a.confidence > b.confidence ? a : b);

          final confidence = (bestDetection.confidence * 100).toStringAsFixed(1);
          
          if (mounted) {
            setState(() {
              _detectedObjectLabel = bestDetection.label;
              _statusMessage = "Detected: ${bestDetection.label} (${confidence}% confidence). Hit Discover!";
            });
          }
        }
      }
    } catch (e) {
      print("Error in Cloud Vision processing: $e");
    }
  }

  Future<void> _processWithMLKit(CameraImage image) async {
    try {
      // Get image rotation
      final camera = _cameraService.controller!;
      final rotation = InputImageRotation.values.firstWhere(
        (element) => element.rawValue == camera.description.sensorOrientation,
        orElse: () => InputImageRotation.rotation0deg,
      );

      // Create InputImage using the first plane of the camera image
      final inputImage = InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final objects = await _objectDetector?.processImage(inputImage);
      if (objects != null && objects.isNotEmpty) {
        final validObjects = objects.where((object) => 
          object.labels.isNotEmpty && 
          object.labels.first.confidence > 0.7 &&
          _targetLabels.contains(object.labels.first.text.toLowerCase())
        ).toList();

        if (validObjects.isNotEmpty) {
          final detectedObject = validObjects.reduce((a, b) => 
            a.labels.first.confidence > b.labels.first.confidence ? a : b);
          
          final label = detectedObject.labels.first.text;
          final confidence = (detectedObject.labels.first.confidence * 100).toStringAsFixed(1);
          
          if (mounted) {
            setState(() {
              _detectedObjectLabel = label;
              _statusMessage = "Detected: $label (${confidence}% confidence). Hit Discover!";
            });
          }
        }
      }
    } catch (e) {
      print("Error in ML Kit processing: $e");
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _objectDetector?.close();
    super.dispose();
  }

  void _toggleCamera() async {
    if (!_isCameraOn) {
      try {
        // Ensure services are initialized if camera controller isn't ready
        if (_cameraService.controller == null || !_cameraService.controller!.value.isInitialized) {
          await _initializeServices(); // This will also start the stream if successful
        } else {
           // If already initialized, just ensure the stream is started
           await _cameraService.controller!.startImageStream(_processCameraImage);
           if (mounted) {
            setState(() {
              _isCameraOn = true;
              _statusMessage = "Point at an object and hit Discover!";
            });
          }
        }
      } catch (e) {
        print("Error toggling camera ON: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to start camera: ${e.toString()}")),
          );
        }
      }
    } else { // Turning camera OFF
      try {
        // Check if controller is not null before stopping stream
        if (_cameraService.controller != null) {
          await _cameraService.controller!.stopImageStream();
        }
      } catch (e) {
         print("Error stopping image stream during toggle OFF: $e");
      }
      if (mounted) {
        setState(() {
          _isCameraOn = false;
          _detectedObjectLabel = "";
          _statusMessage = "Camera is off. Turn it on to discover!";
        });
      }
    }
  }

  Future<void> _discoverObjectAndFetchStory() async {
    if (_isLoading || _detectedObjectLabel.isEmpty) {
      if (_detectedObjectLabel.isEmpty && _isCameraOn && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No specific object detected yet. Point your camera clearly.")),
        );
      } else if (!_isCameraOn && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please turn on the camera first.")),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _statusMessage = "Detected: $_detectedObjectLabel. Crafting its story...";
    });

    String desiredEmotion = "curiosity and wonder";

    try {
      final story = await _geminiService.generateStory(_detectedObjectLabel, desiredEmotion);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryCreationScreen(
              objectLabel: _detectedObjectLabel,
              story: story,
              emotion: desiredEmotion,
            ),
          ),
        ).then((_) {
          if (mounted) {
            setState(() {
               _statusMessage = "Point at an object and hit Discover!";
               _detectedObjectLabel = "";
            });
          }
        });
      }
    } catch (e) {
      print("Error generating story: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Error: Could not generate story for $_detectedObjectLabel.";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Story generation failed: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object & Emotion Finder'),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        actions: [
          // Add toggle switch for Cloud Vision
          Switch(
            value: _useCloudVision,
            onChanged: (value) {
              setState(() {
                _useCloudVision = value;
                _statusMessage = value 
                  ? "Using Cloud Vision API" 
                  : "Using On-device ML Kit";
              });
            },
            activeColor: AppColors.primaryGreen,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Step 1: Let's find something cool!\nPoint your camera at an object.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.primaryText, height: 1.4),
              ),
              const SizedBox(height: 20),

              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_sharp, color: AppColors.darkOrange, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'Realtime Object Detector',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkOrange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.flare_rounded, color: AppColors.darkOrange.withOpacity(0.7), size: 24),
                        ],
                      ),
                      const SizedBox(height: 15),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                             color: Colors.black87,
                             border: Border.all(color: AppColors.primaryColor.withOpacity(0.5), width: 2)
                          ),
                          child: (_isLoading && !_isCameraOn)
                            ? Center(child: CircularProgressIndicator(color: AppColors.accentColor,))
                            : _isCameraOn && _cameraService.controller != null && _cameraService.controller!.value.isInitialized
                                ? CameraPreview(_cameraService.controller!)
                                : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 60),
                                        const SizedBox(height: 10),
                                        Text(
                                          _cameraService.controller == null ? 'Initializing Camera...' : 'Camera is off',
                                          style: TextStyle(color: Colors.white54.withOpacity(0.8), fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _statusMessage,
                          key: ValueKey<String>(_statusMessage),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: CircularProgressIndicator(color: AppColors.accentColor),
                        ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(_isCameraOn ? Icons.videocam_off : Icons.videocam, color: Colors.white),
                            label: Text(_isCameraOn ? 'Turn Off Camera' : 'Turn On Camera', style: const TextStyle(color: Colors.white)),
                            onPressed: _isLoading && _isCameraOn ? null : _toggleCamera,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCameraOn ? Colors.redAccent : AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.auto_awesome, color: Colors.white),
                            label: const Text('Discover!', style: TextStyle(color: Colors.white)),
                            onPressed: _isLoading || _detectedObjectLabel.isEmpty || !_isCameraOn
                                ? null
                                : _discoverObjectAndFetchStory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentColor,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
