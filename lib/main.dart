// main.dart
import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/display.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-page App',
      initialRoute: '/',
      routes: {
        '/': (context) => DisplayPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
