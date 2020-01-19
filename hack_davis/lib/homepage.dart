import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Textbook to audio'),
        ),
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}