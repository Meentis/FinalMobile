import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:milktea/addImage.dart';
import 'package:milktea/editProfil.dart';
import 'package:milktea/main.dart';

class MenuPage extends StatefulWidget {
  final int screenIndex1;
  const MenuPage({Key? key, required this.screenIndex1}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final Random random = Random();
  bool isFavorite = true;
  int screenIndex = 0;
  final mobileScreens = [
    home(),
    profilePage(),
  ];

  void initState() {
    super.initState();
    screenIndex = widget.screenIndex1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mobileScreens[screenIndex],
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 255, 226, 145),
        shape: CircularNotchedRectangle(),
        height: 60,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => addImage()),
          );
        },
        child: Icon(Icons.add_photo_alternate),
        backgroundColor: Color.fromARGB(255, 255, 226, 145),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

//------------- Home page -------------
class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<home> {
  bool isFavorite = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Home',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 226, 145),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              // เพิ่มโค้ดที่ต้องการเมื่อกดปุ่มค้นหา
            },
          ),
        ],
      ),
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

          return SingleChildScrollView(
            child: MasonryView(
              listOfItem: imageUrls,
              numberOfColumn: 2,
              itemBuilder: (item) {
                return Image.network(item);
              },
            ),
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 255, 226, 145),
          actions: [
            IconButton(
              icon: Icon(Icons.logout_outlined),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
                // เพิ่มโค้ดที่ต้องการเมื่อกดปุ่มค้นหา
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                Map<String, dynamic>? userData =
                    snapshot.data?.data() as Map<String, dynamic>?;

                String imageUrl = userData?['image'] ?? '';

                return Column(
                  children: [
                    SizedBox(height: 15),
                    Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all(width: 4, color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                            )
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : AssetImage("img/profile.png")
                                    as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            userData?['username'] ?? "",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(userData?['email'] ?? ""),
                          Text(
                            userData?['caption'] ?? "ไม่มี caption",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                "3",
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "POST",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "1",
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "LIKE",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfile()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 226, 145),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Picture",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('topic')
                            .where('email',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser?.email)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          final List<DocumentSnapshot> documents =
                              snapshot.data!.docs;
                          final List<String> imageUrls = documents
                              .map((doc) => doc['imageUrl'] as String)
                              .toList();

                          if (imageUrls.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical:
                                        40), // เพิ่มระยะห่างตามแนวตั้งที่นี่
                                child: Text('ยังไม่มีรูปภาพ'),
                              ),
                            );
                          }

                          return MasonryView(
                            listOfItem: imageUrls,
                            numberOfColumn: 2,
                            itemBuilder: (item) {
                              return Image.network(item);
                            },
                          );
                        },
                      ),
                    )
                  ],
                );
              }
            },
          ),
        ));
  }
}
