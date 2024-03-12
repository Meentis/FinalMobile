import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:milktea/menupage.dart';

class addImage extends StatefulWidget {
  @override
  _addImageState createState() => _addImageState();
}

class _addImageState extends State<addImage> {
  File? _imageFile;
  User? _user;
  final titlController = TextEditingController();
  final detailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 300, // กำหนดความสูงสูงสุดของรูปภาพ
      maxWidth: 250, // กำหนดความกว้างสูงสุดของรูปภาพ
    );

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

      final TaskSnapshot uploadTask =
          await firebaseStorageRef.putFile(_imageFile!);
      final String imageUrl = await uploadTask.ref.getDownloadURL();

      print('Image uploaded to Firebase Storage.');

      // Add image data to Firestore
      await topicCollection.add({
        'title': titlController.text,
        'detail': detailController.text,
        'imageUrl': imageUrl,
        'email': _user!.email,
      });

      print('Image URL added to Firestore.');
    } catch (e) {
      print(e.toString());
    }
  }

  void _showUploading() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context)
              .pop(true); // เมื่อกระบวนการอัปโหลดเสร็จสิ้น ให้ปิด AlertDialog
        });
        return AlertDialog(
          title: Text("กำลังอัปโหลดรูปภาพ"),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("กรุณารอสักครู่..."),
            ],
          ),
        );
      },
    ).then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MenuPage(
                  screenIndex1: 1,
                )),
      ); // เมื่อกระบวนการอัปโหลดเสร็จสิ้น ให้ปิด AlertDialog
    });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Image',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 226, 145),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            _imageFile != null
                                ? Image.file(_imageFile!)
                                : Text('No image selected.'),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: Text(
                                'Choose Image',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 255, 226, 145),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Title",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: titlController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      hintText:
                                          'Tell others what your iamge is called',
                                      labelStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight
                                              .bold // ขนาดข้อความ Label Text
                                          ),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty)
                                        return "Please add a Title to the iamge";
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 20),
                                  Text(
                                    "Detail",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: detailController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      hintText: 'Add a detail to your iamge',
                                      labelStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight
                                            .bold, // ขนาดข้อความ Label Text
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty)
                                        return "Please add a detail to the iamge";
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_imageFile == null) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Alert",
                                              style: TextStyle(fontSize: 29)),
                                          content: Text(
                                            "Please add a image",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Confirm"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    _showUploading();
                                    _uploadImage();
                                  }
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 255, 226, 145),
                                ), // เปลี่ยนสีปุ่มเป็นสีน้ำเงิน
                              ),
                              child: Text(
                                'Upload Image',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
