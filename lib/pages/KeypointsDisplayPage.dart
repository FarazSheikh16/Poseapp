import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Add this import

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class KeypointsDisplayPage extends StatefulWidget {
  final File imageFile;

  KeypointsDisplayPage({required this.imageFile});

  @override
  _KeypointsDisplayPageState createState() => _KeypointsDisplayPageState();
}

gitclass _KeypointsDisplayPageState extends State<KeypointsDisplayPage> {
  String? _errorMessage;
  bool _isLoading = false;
  List<List<List<dynamic>>> _keypoints = []; // Updated type
  double _keypointSize = 4.0; // Default size of keypoints
  double _lineSize = 2.0; // Default size of lines
  Color _lineColor = Colors.red; // Default color of lines

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
          _keypoints =
              (responseJson as List<dynamic>).map<List<List<dynamic>>>((
                  keypointSet) =>
                  (keypointSet as List<dynamic>).map<List<dynamic>>((
                      keypoint) =>
                      (keypoint as List<dynamic>).map<dynamic>((coordinate) =>
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
      //print(_keypoints);
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
          ? Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Display the image
                Image.file(
                  widget.imageFile,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
                // Overlay keypoints on the image
                Positioned.fill(
                  child: FutureBuilder<ui.Image>(
                    future: decodeImageFromList(
                        widget.imageFile.readAsBytesSync()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.done) {
                        return CustomPaint(
                          painter: KeypointsPainter(
                            _keypoints,
                            snapshot.data!,
                            keypointSize: _keypointSize,
                            lineSize: _lineSize,
                            lineColor: _lineColor,
                          ),
                        );
                      } else {
                        return Container(); // Placeholder until image is loaded
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Keypoint Size'),
                Slider(
                  value: _keypointSize,
                  min: 1,
                  max: 10,
                  onChanged: (value) {
                    print('New Keypoint Size: $value');
                    setState(() {
                      _keypointSize = value;
                    });
                  },
                  label: 'Keypoint Size',
                ),
                SizedBox(height: 10),
                Text('Line Size'),
                Slider(
                  value: _lineSize,
                  min: 1,
                  max: 30,
                  onChanged: (value) {
                    setState(() {
                      _lineSize = value;
                    });
                  },
                  label: 'Line Size',
                ),
                SizedBox(height: 10),
                Text('Line Color'),
                ColorPicker(
                  pickerColor: _lineColor,
                  onColorChanged: (color) {
                    setState(() {
                      _lineColor = color;
                    });
                  },
                  showLabel: false, // Hide the label
                  pickerAreaHeightPercent: 0.0,
                ),
              ],
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
  final List<List<List<dynamic>>> keypoints;
  final ui.Image image;
  final double keypointSize;
  final double lineSize;
  final Color lineColor;

  static const List<List<int>> keypointPairs = [
    [0, 1], [0, 2], [0, 3], [0, 4], [1, 5], [1, 6], [6, 8], [10, 8], [7, 9],
    [6, 12], [7, 5], [11, 12], [11, 5], [12, 14], [13, 11], [13, 15], [14, 16]
  ];

  KeypointsPainter(this.keypoints, this.image,
      {required this.keypointSize, required this.lineSize, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineSize;

    final keypointPaint = Paint()
      ..color = lineColor;

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

    // Draw keypoints and lines between keypoints for each person
    for (var personKeypoints in keypoints) {
      List<List<List<dynamic>>> keypointsLine = [];

      for (var keypointSet in personKeypoints) {
        final x = keypointSet[0] * scaleX + offsetX;
        final y = keypointSet[1] * scaleY + offsetY;
        print('Keypoint: [$x, $y]');

        // Ensure keypoints are within the bounds of the image
        if (x >= 0 && y >= 0 && x <= size.width && y <= size.height) {
          // Draw circle directly on the image
          final keypointRadius = 1.0 * keypointSize;
          if(keypointSet[0]!=0 && keypointSet[1]!=0 )
            canvas.drawCircle(Offset(x, y), keypointRadius, paint);
          keypointsLine.add([[x, y]]); // Store keypoints as [[x, y]]
        }
      }

      // Draw lines between keypoints based on pairs
      for (var pair in keypointPairs) {
        final startPoint = keypointsLine[pair[0]];
        final endPoint = keypointsLine[pair[1]];

        if (startPoint[0][0] != 0 && startPoint[0][1] != 0 &&
            endPoint[0][0] != 0 && endPoint[0][1] != 0) {
          // Draw a line between the keypoints
          canvas.drawLine(Offset(startPoint[0][0], startPoint[0][1]),
              Offset(endPoint[0][0], endPoint[0][1]), paint);
        }
      }

    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


