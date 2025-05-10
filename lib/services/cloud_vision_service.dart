import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class CloudVisionService {
  // TODO: Replace with your actual API key
  static const String _apiKey = 'YOUR_GOOGLE_CLOUD_VISION_API_KEY';
  static const String _apiUrl = 'https://vision.googleapis.com/v1/images:annotate';

  Future<List<VisionDetection>> detectObjects(CameraImage image) async {
    try {
      // Convert camera image to base64
      final bytes = await _processImageToBytes(image);
      final base64Image = base64Encode(bytes);

      // Prepare the API request
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [{
            'image': {'content': base64Image},
            'features': [
              {'type': 'OBJECT_LOCALIZATION', 'maxResults': 10},
              {'type': 'LABEL_DETECTION', 'maxResults': 10}
            ]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<VisionDetection> detections = [];

        // Process object localization results
        if (data['responses']?[0]?['localizedObjectAnnotations'] != null) {
          for (var object in data['responses'][0]['localizedObjectAnnotations']) {
            detections.add(VisionDetection(
              label: object['name'],
              confidence: object['score'].toDouble(),
              boundingBox: _normalizeBoundingBox(object['boundingPoly']['normalizedVertices']),
            ));
          }
        }

        // Process label detection results
        if (data['responses']?[0]?['labelAnnotations'] != null) {
          for (var label in data['responses'][0]['labelAnnotations']) {
            if (!detections.any((d) => d.label.toLowerCase() == label['description'].toLowerCase())) {
              detections.add(VisionDetection(
                label: label['description'],
                confidence: label['score'].toDouble(),
                boundingBox: null,
              ));
            }
          }
        }

        return detections;
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in Cloud Vision detection: $e');
      return [];
    }
  }

  Future<Uint8List> _processImageToBytes(CameraImage image) async {
    try {
      // Convert YUV to RGB
      final img.Image? convertedImage = _convertYUV420toImage(image);
      if (convertedImage == null) throw Exception('Failed to convert image');
      
      // Encode to PNG
      return Uint8List.fromList(img.encodePng(convertedImage));
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }

  img.Image? _convertYUV420toImage(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final img.Image rgbImage = img.Image(width: width, height: height);

      final Plane yPlane = image.planes[0];
      final Plane uPlane = image.planes[1];
      final Plane vPlane = image.planes[2];

      final int yRowStride = yPlane.bytesPerRow;
      final int uvRowStride = uPlane.bytesPerRow;
      final int uvPixelStride = uPlane.bytesPerPixel!;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
          final int index = y * width + x;

          final yp = yPlane.bytes[y * yRowStride + x];
          final up = uPlane.bytes[uvIndex];
          final vp = vPlane.bytes[uvIndex];

          // Convert YUV to RGB
          int r = (yp + vp * 1436 ~/ 1024 - 179).clamp(0, 255);
          int g = (yp - up * 46 ~/ 1024 - vp * 93 ~/ 1024 + 44).clamp(0, 255);
          int b = (yp + up * 1814 ~/ 1024 - 227).clamp(0, 255);

          rgbImage.setPixel(x, y, img.Color.fromRgb(r, g, b));
        }
      }

      return rgbImage;
    } catch (e) {
      print('Error converting YUV to RGB: $e');
      return null;
    }
  }

  Map<String, double> _normalizeBoundingBox(List<dynamic> vertices) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    for (var vertex in vertices) {
      double x = vertex['x'].toDouble();
      double y = vertex['y'].toDouble();
      minX = minX < x ? minX : x;
      minY = minY < y ? minY : y;
      maxX = maxX > x ? maxX : x;
      maxY = maxY > y ? maxY : y;
    }

    return {
      'left': minX,
      'top': minY,
      'width': maxX - minX,
      'height': maxY - minY,
    };
  }
}

class VisionDetection {
  final String label;
  final double confidence;
  final Map<String, double>? boundingBox;

  VisionDetection({
    required this.label,
    required this.confidence,
    this.boundingBox,
  });
} 