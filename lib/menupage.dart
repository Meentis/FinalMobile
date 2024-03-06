import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milktea/addImage.dart';
import 'package:milktea/profile.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final Random random = Random();

  int screenIndex = 0;
  final mobileScreens = [
    home(),
    profilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => profilePage()));
              },
              child: Icon(
                Icons.person,
                color: Colors.black,
                size: 36,
              ),
            ),
          )
        ],
        backgroundColor: Color.fromARGB(255, 255, 226, 145),
      ),
      body: mobileScreens[screenIndex],
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 226, 145),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    //------ กำหนดค่า Index เมื่อมีการคลิก ------
                    screenIndex = 0;
                  });
                },
                icon: Icon(
                  Icons.home,
                  //------ ถ้า Index = 0 ให้ไอคอนสีเหลือง ถ้าไม่ใช้ไอคอนสีขาว ------
                  color: screenIndex == 0
                      ? Color.fromRGBO(254, 254, 254, 1) // สีขาวเมื่อถูกเลือก
                      : const Color.fromARGB(
                          255, 172, 169, 169), // สีเทาเมื่อไม่ได้เลือก
                  // color: Colors.white,
                )),
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.widgets,
                  color: Color.fromARGB(255, 172, 169, 169),
                )),
            IconButton(
                onPressed: () {
                  setState(() {
                    //------ กำหนดค่า Index เมื่อมีการคลิก ------
                    screenIndex = 1;
                  });
                },
                icon: Icon(
                  Icons.person,
                  color: screenIndex == 1
                      ? Color.fromRGBO(254, 254, 254, 1)
                      : const Color.fromARGB(255, 172, 169, 169),
                )),
          ],
        ),
      ),
    );
  }
}

//------------- Home page -------------
class home extends StatelessWidget {
  const home({super.key});
  @override
  Widget build(BuildContext context) {
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
              .map((doc) => doc['imageUrl'] as String)
              .toList(); // รับ URL ของรูปภาพจาก documents

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // จำนวนรูปภาพในแนวแกนนอน
              crossAxisSpacing: 2.0, // ระยะห่างระหว่างรูปภาพในแนวแกนนอน
              mainAxisSpacing: 2.0, // ระยะห่างระหว่างรูปภาพในแนวแกนตั้ง
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final String imageUrl =
                  imageUrls[index]; // นำ URL ของรูปภาพที่ได้มาแสดงผล
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        // จัดการการคลิกรูปภาพ
                      },
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

//------------- profile Page -------------
class profilePage extends StatefulWidget {
  const profilePage({Key? key}) : super(key: key);

  @override
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => addImage()),
          );
        },
        label: Icon(Icons.add_photo_alternate),
        backgroundColor: Color.fromARGB(255, 255, 226, 145),
      ),
    );
  }
}
