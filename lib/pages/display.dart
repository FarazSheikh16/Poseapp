import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'KeypointsDisplayPage.dart'; // Import the KeypointsDisplayPage

class DisplayPage extends StatefulWidget {
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  XFile? _selectedImage;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
        _errorMessage = null;
      });
    }
  }

  Future<void> _sendImageToApi(File imageFile) async {
    final apiUrl = Uri.parse('http://10.25.24.175:5000/api/infer'); // Replace with your API URL
    final request = http.MultipartRequest('POST', apiUrl);
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
    ));

    try {
      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        final responseJson = await streamedResponse.stream.bytesToString();
        final parsedResponse = json.decode(responseJson);
        _downloadJsonFile(parsedResponse);
      } else {
        setState(() {
          _errorMessage = 'Error: ${streamedResponse.reasonPhrase}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _downloadJsonFile(dynamic response) async {
    final jsonData = utf8.encode(jsonEncode(response));
    final file = File('${_selectedImage!.path}_response.json');
    await file.writeAsBytes(jsonData);
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('JSON file downloaded'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
            if (_selectedImage != null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _sendImageToApi(File(_selectedImage!.path));
                },
                child: Text('Download JSON File'),
              ),
            if (_selectedImage != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KeypointsDisplayPage(imageFile: File(_selectedImage!.path)),
                    ),
                  );
                },
                child: Text('Display keypoints'),
              ),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
