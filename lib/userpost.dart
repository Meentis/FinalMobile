import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:milktea/imagedetails.dart';

class UserPost extends StatelessWidget {
  UserPost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // ไม่ได้ล็อคอิน
      return Center(
        child: Text('กรุณาล็อคอินเพื่อดูรูปภาพ'),
      );
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('topic').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          final List<String> imageUrls = documents
              .where((doc) =>
                  doc['imageUrl'] != null &&
                  doc['imageUrl'] != "" &&
                  doc['email'] == user.email) // กรองตามอีเมลของผู้ใช้
              .map((doc) => doc['imageUrl'] as String)
              .toList();

          if (imageUrls.isEmpty) {
            // ไม่พบรูปภาพสำหรับผู้ใช้นี้
            return Center(
              child: Text('No images found for this user'),
            );
          }

          return SingleChildScrollView(
            child: MasonryGrid(
              column: 2,
              children: imageUrls.map((imageUrl) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDetailPage(
                            imageUrl: imageUrl,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
