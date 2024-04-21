import 'dart:io';
import 'dart:convert';
import 'dart:math';
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

class _KeypointsDisplayPageState extends State<KeypointsDisplayPage> {
  String? _errorMessage;
  bool _isLoading = false;
  List<List<List<dynamic>>> _keypoints = []; // Updated type
  double _keypointSize = 4.0; // Default size of keypoints
  double _lineSize = 2.0; // Default size of lines
  Color _lineColor = Colors.red; // Default color of lines
  bool _showOptions = false; // Variable to control the visibility of options
  bool _showAngles = false;
   // Variable to control the visibility of angles
  // Map of index labels for each keypoint
   Map<int, String> _keypointLabels = {
    0: 'Nose',
    1: 'Left eye',
    2: 'Right eye',
    3: 'Left ear',
    4: 'Right ear',
    5: 'Left shoulder',
    6: 'Right shoulder',
    7: 'Left elbow',
    8: 'Right elbow',
    9: 'Left wrist',
    10: 'Right wrist',
    11: 'Left hip',
    12: 'Right hip',
    13: 'Left knee',
    14: 'Right knee',
    15: 'Left ankle',
    16: 'Right ankle',
  };

  // Variable to hold the tapped label
  String? _tappedLabel;

  @override
  void initState() {
    super.initState();
    _sendImageToApi(widget.imageFile);
  }

  Future<void> _sendImageToApi(File imageFile) async {
    final apiUrl = Uri.parse('http://10.25.24.175:5000/api/infer');
    final request = http.MultipartRequest('POST', apiUrl);
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      setState(() {
        _isLoading = true; // Set loading state
        _errorMessage = null; // Reset error message
      });

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        final responseString = await streamedResponse.stream.bytesToString();
        final responseJson = jsonDecode(responseString);
        setState(() {
          _keypoints = (responseJson as List<dynamic>).map<List<List<dynamic>>>(
                (keypointSet) => (keypointSet as List<dynamic>).map<List<dynamic>>(
                  (keypoint) => (keypoint as List<dynamic>).map<dynamic>(
                    (coordinate) => coordinate.toDouble(),
              ).toList(),
            ).toList(),
          ).toList();
          _isLoading = false;
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
          ? Column(
        children: [
          _showOptions
              ? Container(
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
          )
              : Container(),
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
                  child: GestureDetector(
                    onTapDown: (details) {
                      // Get the tap position
                      final tapPosition = details.localPosition;

                      // Find the closest keypoint to the tap position
                      int closestKeypointIndex = findClosestKeypoint(tapPosition);

                      // Set the tapped label
                      setState(() {
                        _tappedLabel = _keypointLabels[closestKeypointIndex];
                      });
                    },
                    child: FutureBuilder<ui.Image>(
                      future: decodeImageFromList(widget.imageFile.readAsBytesSync()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CustomPaint(
                            painter: KeypointsPainter(
                              _keypoints,
                              snapshot.data!,
                              keypointSize: _keypointSize,
                              lineSize: _lineSize,
                              lineColor: _lineColor,
                              showAngles: _showAngles,
                              tappedLabel: _tappedLabel,
                              keypointLabels: _keypointLabels,
                            ),
                          );
                        } else {
                          return Container(); // Placeholder until image is loaded
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showOptions = !_showOptions;
                  });
                },
                child: Text(_showOptions ? 'Hide Options' : 'Show Options'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAngles = !_showAngles;
                  });
                },
                child: Text(_showAngles ? 'Hide Angles' : 'Show Angles'),
              ),
            ],
          ),
        ],
      )
          : Center(
        child: Text('No keypoints found.'),
      ),
    );
  }

  // Function to find the closest keypoint to the tap position
  int findClosestKeypoint(Offset tapPosition) {
    double minDistance = double.infinity;
    int closestKeypointIndex = -1;

    for (var personKeypoints in _keypoints) {
      for (var keypointSet in personKeypoints) {
        final x = keypointSet[0];
        final y = keypointSet[1];
        final keypointPosition = Offset(x, y);
        final distance = (tapPosition - keypointPosition).distance;

        if (distance < minDistance) {
          minDistance = distance;
          closestKeypointIndex = personKeypoints.indexOf(keypointSet);
        }
      }
    }

    return closestKeypointIndex;
  }
}

class KeypointsPainter extends CustomPainter {
  final List<List<List<dynamic>>> keypoints;
  final ui.Image image;
  final double keypointSize;
  final double lineSize;
  final Color lineColor;
  final bool showAngles;
  final String? tappedLabel;
  final Map<int, String> keypointLabels;// Tapped label to be displayed in a box

  static const List<List<int>> keypointPairs = [
    [0, 1], [0, 2], [0, 3], [0, 4], [1, 5], [1, 6], [6, 8], [10, 8], [7, 9],
    [6, 12], [7, 5], [11, 12], [11, 5], [12, 14], [13, 11], [13, 15], [14, 16]
  ];

  KeypointsPainter(this.keypoints, this.image,
      {required this.keypointSize, required this.lineSize, required this.lineColor, required this.showAngles, this.tappedLabel, required this.keypointLabels});

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

          // Draw label box if tapped label matches current keypoint
          if (tappedLabel != null && keypointLabels.containsValue(tappedLabel)) {
            final index = keypointLabels.keys.firstWhere((key) => keypointLabels[key] == tappedLabel);
            if (personKeypoints.indexOf(keypointSet) == index) {
              final text = TextSpan(text: tappedLabel, style: TextStyle(color: Colors.black));
              final textPainter = TextPainter(text: text, textDirection: TextDirection.ltr);
              textPainter.layout();
              final labelWidth = textPainter.width + 10;
              final labelHeight = textPainter.height + 5;
              final rect = Rect.fromLTWH(x - labelWidth / 2, y - labelHeight - keypointRadius - 5, labelWidth, labelHeight);
              final roundedRect = RRect.fromRectAndRadius(rect, Radius.circular(5));
              canvas.drawRRect(roundedRect, Paint()..color = Colors.white);
              textPainter.paint(canvas, Offset(x - labelWidth / 2 + 5, y - labelHeight - keypointRadius));
            }
          }
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

          // Show angles if enabled
          if (showAngles) {
            final angle = calculateAngle(startPoint[0], endPoint[0]);
            final textPainter = TextPainter(
              text: TextSpan(
                text: '${angle.toStringAsFixed(2)}°',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            final textX = (startPoint[0][0] + endPoint[0][0]) / 2;
            final textY = (startPoint[0][1] + endPoint[0][1]) / 2;
            textPainter.paint(canvas, Offset(textX, textY));
          }
        }
      }
    }
  }

  double calculateAngle(List<dynamic> startPoint, List<dynamic> endPoint) {
    final dx = endPoint[0] - startPoint[0];
    final dy = endPoint[1] - startPoint[1];
    final radians = atan2(dy, dx);
    return radians * 180 / pi;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
