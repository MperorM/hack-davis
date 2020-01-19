import 'package:flutter/material.dart';
import 'package:hack_davis/cameraapp.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http; 

class homepage extends StatefulWidget{
  final CameraDescription camera;
  const homepage(this.camera);

  @override
  homepageState createState() {
    return homepageState();
  }
}

class homepageState extends State<homepage>{
  File image;
  AudioPlayer audioPlayer = AudioPlayer();


  Future<void>play(url) async {
    int result = await audioPlayer.play(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      camera: widget.camera
                    )
                  ),
                );
                if (image != null) {
                  final StorageReference storageReference = FirebaseStorage().ref().child('1.jpg');
                  final StorageUploadTask uploadTask = storageReference.putFile(image);

                  final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event) {
                    // You can use this to notify yourself or your user in any kind of way.
                    // For example: you could use the uploadTask.events stream in a StreamBuilder instead
                    // to show your user what the current status is. In that case, you would not need to cancel any
                    // subscription as StreamBuilder handles this automatically.

                    // Here, every StorageTaskEvent concerning the upload is printed to the logs.
                    print('EVENT ${event.type}');
                  });
                  await uploadTask.onComplete;
                  streamSubscription.cancel();
                }
              },
              child: Text("Take picture")
            ),
            RaisedButton(
              onPressed: () async {
                print(image);
                if (image != null) {
                  http.Response oneTimeUrl = await http.get('https://us-central1-davishack.cloudfunctions.net/analyse_image' + '?image=' + '1.jpg');
                  play(oneTimeUrl.body);
                } else {
                  //Scaffold.of(context).showSnackBar(SnackBar(content: Text("no image taken")));
                }
              },
              child: Text("listen to picture")
            )
          ],
        )
      ),
    );
  }
}