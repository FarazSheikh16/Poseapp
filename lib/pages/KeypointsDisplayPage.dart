import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class KeypointsDisplayPage extends StatefulWidget {
  final File imageFile;

  KeypointsDisplayPage({required this.imageFile});

  @override
  _KeypointsDisplayPageState createState() => _KeypointsDisplayPageState();
}

class _KeypointsDisplayPageState extends State<KeypointsDisplayPage> {
  String? _errorMessage;
  bool _isLoading = false;
  List<dynamic> _keypoints = [];

  @override
  void initState() {
    super.initState();
    _sendImageToApi(widget.imageFile);
  }

  Future<void> _sendImageToApi(File imageFile) async {
    final apiUrl = Uri.parse('http://10.25.24.175:5000/api/infer');
    final request = http.MultipartRequest('POST', apiUrl);
    request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      setState(() {
        _isLoading = false; // Set loading state
        _errorMessage = null; // Reset error message
      });

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        final responseString = await streamedResponse.stream.bytesToString();
        final responseJson = jsonDecode(responseString);
        setState(() {
          _keypoints = (responseJson as List<dynamic>).map<List<List<double>>>((
              keypointSet) =>
              (keypointSet as List<dynamic>).map<List<double>>((keypoint) =>
                  (keypoint as List<dynamic>).map<double>((coordinate) =>
                      coordinate.toDouble()).toList()
              ).toList()
          ).toList();
        });
      } else {
        final errorMessage = 'Error: ${streamedResponse.reasonPhrase}';
        print('ERROR: $errorMessage');
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
      }
    } catch (e) {
      final errorMessage = 'Error: $e';
      print('ERROR: $errorMessage');
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keypoints Display'),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : _errorMessage != null
          ? Center(
        child: Text(_errorMessage!),
      )
          : _keypoints.isNotEmpty
          ? Stack(
        children: [
          // Display the image
          Image.file(
            widget.imageFile,
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
            //fit: FittedBox.fill,
          ),
          // Overlay keypoints on the image
          Positioned.fill(
            child: FutureBuilder<ui.Image>(
              future: decodeImageFromList(widget.imageFile.readAsBytesSync()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CustomPaint(
                    painter: KeypointsPainter(_keypoints, snapshot.data!),
                  );
                } else {
                  return Container(); // Placeholder until image is loaded
                }
              },
            ),
          ),
        ],
      )
          : Center(
        child: Text('No keypoints found.'),
      ),
    );
  }
}

class KeypointsPainter extends CustomPainter {
  final List<dynamic> keypoints;
  final ui.Image image;

  KeypointsPainter(this.keypoints, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0;

    final aspectRatio = image.width / image.height;
    final displayAspectRatio = size.width / size.height;

    double scaleX, scaleY;

    if (aspectRatio > displayAspectRatio) {
      scaleX = size.width / image.width;
      scaleY = scaleX;
    } else {
      scaleY = size.height / image.height;
      scaleX = scaleY;
    }

    final offsetX = (size.width - image.width * scaleX) / 2;
    final offsetY = (size.height - image.height * scaleY) / 2;

    for (var keypointSet in keypoints) {
      for (var keypoint in keypointSet) {
        final x = keypoint[0] * scaleX + offsetX;
        final y = keypoint[1] * scaleY + offsetY;

        // Ensure keypoints are within the bounds of the image
        if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
          // Draw circle directly on the image
          canvas.drawCircle(Offset(x, y), 4.0, paint);
        }
      }
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
