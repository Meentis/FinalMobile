import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class addImage extends StatefulWidget {
  @override
  _addImageState createState() => _addImageState();
}

class _addImageState extends State<addImage> {
  File? _imageFile;
  User? _user;
  final titlController = TextEditingController();
  final detailController = TextEditingController();

  CollectionReference topicCollection =
      FirebaseFirestore.instance.collection('topic');

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = currentUser;
    });
  }

  // Function สำหรับเลือกรูปภาพจากแกลเลอรี่
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Function สำหรับอัพโหลดรูปภาพลง Firebase Storage
  Future<void> _uploadImage() async {
    if (_imageFile == null || _user == null) return;

    String imageName = titlController.text;
    String imageData = detailController.text;

    if (imageName.isEmpty || imageData.isEmpty) {
      print('Please enter image name and data.');
      return;
    }

    try {
      final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
          'images/${_user!.email}/$imageName-${DateTime.now().millisecondsSinceEpoch}.png');

      await firebaseStorageRef.putFile(_imageFile!);

      print('Image uploaded to Firebase Storage.');
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image to Firebase Storage'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              _getUser();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageFile != null
                  ? Image.file(_imageFile!)
                  : Text('No image selected.'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Choose Image'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: titlController,
                decoration: InputDecoration(
                  labelText: 'titl',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: detailController,
                decoration: InputDecoration(
                  labelText: 'Details',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _uploadImage();
                  topicCollection.add({
                    'title': titlController.text,
                    'conversation': detailController.text
                  });
                },
                child: Text('Upload Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
