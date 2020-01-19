import 'package:flutter/material.dart';
import 'package:hack_davis/cameraapp.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    File image;

    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Textbook to audio'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  image = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TakePictureScreen(
                        camera: this.camera
                      )
                    ),
                  );
                },
                child: Text("take picture")
              ),
            ],
          )
        ),
      ),
    );
  }
}