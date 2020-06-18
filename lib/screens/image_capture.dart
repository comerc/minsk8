import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:minsk8/import.dart';

class ImageCaptureScreen extends StatefulWidget {
  createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File _imageFile;

  /// Cropper plugin
  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      // ratioX: 1,
      // ratioY: 1,
      // maxWidth: 512,
      // maxHeight: 512,
      androidUiSettings: AndroidUiSettings(
        toolbarColor: Colors.purple,
        toolbarWidgetColor: Colors.white,
        toolbarTitle: 'Crop It',
        // hideBottomControls: true,
      ),
      compressFormat: ImageCompressFormat.png,
      compressQuality: 100,
      // cropStyle: CropStyle.circle,
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
  }

  void _clear() {
    setState(() => _imageFile = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Capture'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.photo_camera,
                // size: 30,
              ),
              onPressed: () => _pickImage(ImageSource.camera),
              color: Colors.blue,
              tooltip: 'Take a Photo',
            ),
            IconButton(
              icon: Icon(
                Icons.photo_library,
                // size: 30,
              ),
              onPressed: () => _pickImage(ImageSource.gallery),
              color: Colors.pink,
              tooltip: 'Pick Image from gallery',
            ),
          ],
        ),
      ),
      drawer: MainDrawer('/image_capture'),
      body: Column(
        children: [
          if (_imageFile != null) ...[
            Container(
                padding: EdgeInsets.all(32), child: Image.file(_imageFile)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton(
                  child: Icon(Icons.crop),
                  onPressed: _cropImage,
                ),
                FlatButton(
                  child: Icon(Icons.refresh),
                  onPressed: _clear,
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32),
              child: Uploader(
                file: _imageFile,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  final File file;

  Uploader({Key key, this.file}) : super(key: key);

  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: kStorageBucket);

  StorageUploadTask _uploadTask;

  _startUpload() {
    String filePath = 'images/${DateTime.now()} ${Uuid().v4()}.png';

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
    });
  }

  getDownloadUrl() async {
    final downloadUrl = await _uploadTask.lastSnapshot.ref.getDownloadURL();
    print(downloadUrl);
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (context, snapshot) {
            var event = snapshot?.data?.snapshot;

            double progressPercent = event != null
                ? event.bytesTransferred / event.totalByteCount
                : 0;

            if (_uploadTask.isComplete) {
              getDownloadUrl();
            }

            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_uploadTask.isComplete)
                    Text('🎉🎉🎉',
                        style: TextStyle(
                            color: Colors.greenAccent,
                            height: 2,
                            fontSize: 30)),
                  if (_uploadTask.isPaused)
                    FlatButton(
                      child: Icon(Icons.play_arrow, size: 50),
                      onPressed: _uploadTask.resume,
                    ),
                  if (_uploadTask.isInProgress)
                    FlatButton(
                      child: Icon(Icons.pause, size: 50),
                      onPressed: _uploadTask.pause,
                    ),
                  LinearProgressIndicator(value: progressPercent),
                  Text(
                    '${(progressPercent * 100).toStringAsFixed(2)} % ',
                    style: TextStyle(fontSize: 50),
                  ),
                ]);
          });
    } else {
      return FlatButton.icon(
          color: Colors.blue,
          label: Text('Upload to Firebase'),
          icon: Icon(Icons.cloud_upload),
          onPressed: _startUpload);
    }
  }
}
