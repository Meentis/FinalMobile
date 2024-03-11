import 'package:firebase_auth/firebase_auth.dart';
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
  late String detail = '';
  late String userEmail = '';

  bool isFavorite = true;
  late String userName = '';
  late String caption = '';
  late String profileImage =
      'https://firebasestorage.googleapis.com/v0/b/milktea-13bba.appspot.com/o/profile.png?alt=media&token=dd3912db-c907-4541-a396-c0102b5a34e6';

  @override
  void initState() {
    super.initState();
    fetchImageData();
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
          detail = snapshot['detail'];
          userEmail = snapshot['email'];
          userName = snapshot['username'];
          // เรียกใช้ฟังก์ชันเพื่อตรวจสอบว่าภาพนี้เป็น favorite หรือไม่
          checkIfFavorite();
        });
      }
    } catch (e) {
      print('Error fetching image data: $e');
      // Handle error gracefully, show a snackbar or retry option
    }
  }

  Future<void> checkIfFavorite() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('favorite')
          .where('imageUrl', isEqualTo: widget.imageUrl)
          .get();

      setState(() {
        isFavorite = querySnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print('Error checking if image is favorite: $e');
    }
  }

  Future<void> addToFavorites() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('favorite').add({
          'imageUrl': widget.imageUrl,
          'title': title,
          'detail': detail,
          'email': userEmail,
          'username': userName,
          'your_email': user.email, // ใช้อีเมลของผู้ใช้ที่ล็อกอินอยู่
          // เพิ่มข้อมูลอื่น ๆ ที่ต้องการเก็บในตาราง favorite
        });
        setState(() {
          isFavorite = true;
        });
      }
    } catch (e) {
      print('Error adding image to favorites: $e');
    }
  }

  Future<void> removeFromFavorites() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('favorite')
          .where('imageUrl', isEqualTo: widget.imageUrl)
          .limit(1) // จำกัดให้ลบเพียงหนึ่งเรคคอร์ด
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.first.reference.delete();
        setState(() {
          isFavorite = false;
        });
      }
    } catch (e) {
      print('Error removing image from favorites: $e');
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
                  'Detail: $detail',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(profileImage),
                    ),
                    SizedBox(width: 13),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'Loading...',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userEmail,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      onPressed:
                          isFavorite ? removeFromFavorites : addToFavorites,
                      icon: isFavorite
                          ? Icon(Icons.favorite, color: Colors.red)
                          : Icon(Icons.favorite_border),
                    )
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
