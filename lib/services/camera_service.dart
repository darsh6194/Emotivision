import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request camera permission
    final status = await Permission.camera.request();
    if (status.isDenied) {
      throw Exception('Camera permission is required');
    }

    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Initialize with the first (back) camera
      controller = CameraController(
        cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing camera: $e');
      throw Exception('Failed to initialize camera: $e');
    }
  }

  void dispose() {
    controller?.dispose();
    _isInitialized = false;
  }

  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (!_isInitialized) {
      throw Exception('Camera not initialized');
    }

    try {
      await controller!.startImageStream(onImage);
    } catch (e) {
      print('Error starting image stream: $e');
      throw Exception('Failed to start camera stream: $e');
    }
  }

  Future<void> stopImageStream() async {
    if (!_isInitialized) return;

    try {
      await controller!.stopImageStream();
    } catch (e) {
      print('Error stopping image stream: $e');
    }
  }
} 