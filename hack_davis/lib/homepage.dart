import 'package:flutter/material.dart';
import 'package:hack_davis/cameraapp.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

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
                  if (image != null) {
                    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
                    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
                    final VisionText visionText = await textRecognizer.processImage(visionImage);
                    String text = visionText.text;
                    for (TextBlock block in visionText.blocks) {
                      final Rect boundingBox = block.boundingBox;
                      final List<Offset> cornerPoints = block.cornerPoints;
                      final String text = block.text;
                      final List<RecognizedLanguage> languages = block.recognizedLanguages;

                      for (TextLine line in block.lines) {
                        // Same getters as TextBlock
                        for (TextElement element in line.elements) {
                          // Same getters as TextBlock
                        }
                      }
                    }
                  print(text);
                  textRecognizer.close();
                  }
                },
                child: Text("Take picture")
              ),
            ],
          )
        ),
      ),
    );
  }
}