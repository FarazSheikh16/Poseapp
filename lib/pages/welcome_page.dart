// pages/welcome_page.dart
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Set a delay to start the animation after a short period
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PR POSE',
          style: TextStyle(
            fontFamily: 'Roboto', // Example of using a custom font
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            letterSpacing: 1.5, // Adjust letter spacing for better readability
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Set the background color of the app bar
        elevation: 2.0, // Add a subtle shadow to the app bar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200, // Fixed width for the icons
              height: 200, // Fixed height for the icons
              child: Image(image: AssetImage('assets/icons/lablogo.png')),
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _visible ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Discover perfect poses with precision!',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20), // Add some space between text and buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('LOGIN'),
            ),
            SizedBox(height: 10), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to sign up/register page
              },
              child: Text('SIGN UP/Register'),
            ),
            SizedBox(height: 10), // Add some space between buttons and icons row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48, // Fixed width for the icons
                  height: 48, // Fixed height for the icons
                  child: IconButton(
                    icon: Image(image: AssetImage('assets/icons/google.png')),
                    onPressed: () {
                      // Handle Google sign-in
                    },
                  ),
                ),
                SizedBox(
                  width: 48, // Fixed width for the icons
                  height: 48, // Fixed height for the icons
                  child: IconButton(
                    icon: Image(image: AssetImage('assets/icons/facebook.png')),
                    onPressed: () {
                      // Handle Facebook sign-in
                    },
                  ),
                ),
                SizedBox(
                  width: 48, // Fixed width for the icons
                  height: 48, // Fixed height for the icons
                  child: IconButton(
                    icon: Image(image: AssetImage('assets/icons/outlook.png')),
                    onPressed: () {
                      // Handle Outlook sign-in
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
