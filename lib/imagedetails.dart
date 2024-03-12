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
  late String caption = '';
  late String userEmail = '';
  bool isFavorite = false; // ตั้งค่าเริ่มต้นให้ไม่ได้ถูกไลค์
  late String username = '';
  late String detail = '';
  late String profileimage = '';
  bool isLoading =
      true; // เพิ่มตัวแปร isLoading เพื่อตรวจสอบว่ากำลังโหลดข้อมูลหรือไม่

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
          userEmail = snapshot['email'];
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
          .where('email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot snapshot = querySnapshot.docs.first;
        String? email = snapshot['email'];
        print('Email from Firestore: $email');
        if (email != null) {
          setState(() {
            profileimage = snapshot['image'];
            username = snapshot['username'];

            userEmail = email;
            isLoading =
                false; // ตั้งค่า isLoading เป็น false เมื่อโหลดข้อมูลเสร็จสิ้น
          });
          await checkIfFavorite(); // เรียกเมท็อดเพื่อตรวจสอบว่ารูปภาพถูกไลค์หรือไม่
        } else {
          print('Error: Email is null');
        }
      }
    } catch (e) {
      print('Error fetching image data: $e');
    }
  }

  Future<void> checkIfFavorite() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('favorite')
          .where('imageUrl', isEqualTo: widget.imageUrl)
          .where('liked_by',
              arrayContains: FirebaseAuth.instance.currentUser!
                  .email) // ตรวจสอบว่าอีเมลของผู้ใช้ที่ล็อกอินอยู่ได้ถูกไลค์หรือไม่
          .get();

      setState(() {
        isFavorite = querySnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print('Error checking if image is favorite: $e');
    }
  }

  Future<void> toggleLike() async {
    setState(() {
      isFavorite = !isFavorite;
    });
    if (isFavorite) {
      await addToFavorites(); // เรียกใช้ฟังก์ชัน addToFavorites ในกรณีที่ถูกไลค์
    } else {
      await removeFromFavorites();
    }
    setState(() {}); // รีเฟรช FutureBuilder
  }

  Future<void> addToFavorites() async {
    try {
      await FirebaseFirestore.instance
          .collection('favorite')
          .where('imageUrl', isEqualTo: widget.imageUrl)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          // อัปเดตข้อมูลของเอกสารที่มี imageUrl เท่ากับ widget.imageUrl
          querySnapshot.docs.first.reference.update({
            'liked_by': FieldValue.arrayUnion(
                [FirebaseAuth.instance.currentUser!.email])
          });
        } else {
          // ถ้าไม่มีเอกสารที่มี imageUrl เท่ากับ widget.imageUrl ในฐานข้อมูล
          // ให้เพิ่มข้อมูลเข้าไปในฐานข้อมูล
          FirebaseFirestore.instance.collection('favorite').add({
            'imageUrl': widget.imageUrl,
            'title': title,
            'detail': detail,
            'email': userEmail,
            'liked_by': [
              FirebaseAuth.instance.currentUser!.email
            ], // เพิ่มอีเมลของผู้ใช้ที่ได้ถูกไลค์
            // เพิ่มข้อมูลอื่น ๆ ที่ต้องการเก็บในตาราง favorite
          });
        }
      });
    } catch (e) {
      print('Error adding image to favorites: $e');
    }
  }

  Future<void> removeFromFavorites() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('favorite')
          .where('imageUrl', isEqualTo: widget.imageUrl)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        List<String> likedBy = List<String>.from(doc['liked_by']);
        if (likedBy.contains(FirebaseAuth.instance.currentUser!.email)) {
          likedBy.remove(FirebaseAuth.instance.currentUser!.email);
          await doc.reference.update({'liked_by': likedBy});
        }
      }
    } catch (e) {
      print('Error removing image from favorites: $e');
    }
  }

  Future<int> fetchLikeCount() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('favorite')
          .where('imageUrl', isEqualTo: widget.imageUrl)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot snapshot = querySnapshot.docs.first;
        List<dynamic> likedBy = snapshot['liked_by'];
        return likedBy.length;
      } else {
        return 0; // หากไม่มีเอกสารในฐานข้อมูลเกี่ยวกับภาพนี้
      }
    } catch (e) {
      print('Error fetching like count: $e');
      return 0; // หากเกิดข้อผิดพลาดในการดึงข้อมูล
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    height: 400,
                    width: 400,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
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
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
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
                                  userEmail,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: toggleLike,
                              icon: isFavorite
                                  ? Icon(Icons.favorite, color: Colors.red)
                                  : Icon(Icons.favorite_border),
                            ),
                            FutureBuilder<int>(
                              key: UniqueKey(), // เพิ่ม key ที่เป็น UniqueKey()
                              future: fetchLikeCount(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Text(
                                    'Liked by: ${snapshot.data}',
                                    style: TextStyle(fontSize: 16),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
