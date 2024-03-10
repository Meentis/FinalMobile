import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageDetailPage extends StatefulWidget {
  final String imageUrl;

  ImageDetailPage({required this.imageUrl});

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  late String title = 'Title';
  late String caption = '';
  late String userProfile = '';
  bool isFavorite = true;
  late String username = '';
  late String detail = '';
  late String profileimage = '';
  @override
  void initState() {
    super.initState();
    fetchImageData();
    fetchUserData();
  }

  Future<void> fetchImageData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('topic')
          .where('imageUrl', isEqualTo: widget.imageUrl)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot snapshot = querySnapshot.docs.first;
        setState(() {
          title = snapshot['title'];
          detail = snapshot['detail']; // เพิ่มการรับค่า caption จาก Firestore
          userProfile = snapshot['email'];
          // เพิ่มการรับค่าโปรไฟล์ผู้ใช้จาก Firestore
          fetchUserData(); // เรียกเมท็อดเพื่อดึงข้อมูลโปรไฟล์ผู้ใช้
        });
      }
    } catch (e) {
      print('Error fetching image data: $e');
    }
  }

  Future<void> fetchUserData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userProfile)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot snapshot = querySnapshot.docs.first;
        setState(() {
          profileimage = snapshot['image'];
          username = snapshot['username'];
          caption = snapshot['caption']; // เพิ่มการรับค่า caption จาก Firestore
          userProfile =
              snapshot['email']; // เพิ่มการรับค่าโปรไฟล์ผู้ใช้จาก Firestore
          print('$username');
        });
      }
    } catch (e) {
      print('Error fetching image data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 400,
              width: 400,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Detail: $detail', // แสดงคำอธิบายรูปภาพ
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(profileimage),
                    ),
                    SizedBox(width: 13),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userProfile, // แสดงโปรไฟล์ผู้ใช้
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      icon: isFavorite
                          ? Icon(Icons.favorite_border)
                          : Icon(Icons.favorite, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
