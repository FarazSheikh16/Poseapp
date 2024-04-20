import 'package:flutter/material.dart';
import 'display.dart';// Import your display page here

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Check if email is 'faraz' and password is '123'
                if (_emailController.text == 'faraz' && _passwordController.text == '123') {
                  // If credentials are correct, navigate to the display page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DisplayPage()),
                  );
                } else {
                  // If credentials are incorrect, display an error message
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Login Failed'),
                        content: Text('Incorrect email or password. Please try again.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
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
