// pages/login_page.dart
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LOG IN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 200, // Fixed width for the icons
              height: 200, // Fixed height for the icons
              child: Image(image: AssetImage('assets/icons/lablogo.png')),
            ),
            Text(
              'Pose Perfectly with Us',
              style: TextStyle(
                fontSize: 28.0, // Increased font size for prominence
                fontWeight: FontWeight.bold, // Added boldness for emphasis
                color: Colors.blue, // Set text color to blue for added attention
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform login action
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Set background color to blue
              ),
              child: Text('LOGIN'),

            ),

            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to forgot password page
              },
              child: Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}
