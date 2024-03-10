import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:milktea/addImage.dart';
import 'package:milktea/editprofil.dart';
import 'package:milktea/imagedetails.dart';
import 'package:milktea/main.dart';
import 'package:milktea/userpoast.dart';

class MenuPage extends StatefulWidget {
  final int screenIndex1;
  const MenuPage({Key? key, required this.screenIndex1}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final Random random = Random();

  int screenIndex = 0;
  final mobileScreens = [
    Home(),
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
                    screenIndex = 0;
                  });
                },
                icon: Icon(
                  Icons.edit,
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
                    screenIndex = 0;
                  });
                },
                icon: Icon(
                  Icons.favorite,
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
class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('คุณต้องการออกหรือไม่?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // ปิดกล่องข้อความ
                        },
                        child: Text('ยกเลิก'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                          // เพิ่มโค้ดที่ต้องการเมื่อคุณต้องการออก
                        },
                        child: Text('ออก'),
                      ),
                    ],
                  );
                },
              );
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
            child: MasonryGrid(
              column: 2,
              children: imageUrls.map((imageUrl) {
                return Padding(
                  padding: const EdgeInsets.all(8.0), // ระยะห่างระหว่างรูปภาพ
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
                      borderRadius:
                          BorderRadius.circular(10), // ปรับขอบรูปภาพให้โค้ง
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit
                            .cover, // ทำให้รูปภาพปรับตามขนาดของพื้นที่ที่กำหนด
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

//------------- profile Page -------------
class profilePage extends StatefulWidget {
  const profilePage({Key? key}) : super(key: key);
  @override
  _profilePageState createState() => _profilePageState();
}

//SingleTickerProviderStateMixin ช่วยในการสร้าง Animation หรือการควบคุมการเลื่อนหน้าจอ ทำให้ State นี้สามารถใช้ TabController
class _profilePageState extends State<profilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('คุณต้องการออกหรือไม่?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // ปิดกล่องข้อความ
                        },
                        child: Text('ยกเลิก'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                          // เพิ่มโค้ดที่ต้องการเมื่อคุณต้องการออก
                        },
                        child: Text('ออก'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: FutureBuilder<DocumentSnapshot>(
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
                            : AssetImage("img/profile.png") as ImageProvider,
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
                        userData?['caption'] ?? "",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
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
                            "1600",
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
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
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
                Container(
                  child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.amber,
                      tabs: [
                        Tab(
                          icon: Icon(
                            Icons.post_add,
                            color: Colors.black,
                          ),
                        ),
                        Tab(
                          icon: Icon(Icons.favorite, color: Colors.black),
                        )
                      ]),
                ),
                Container(
                  width: double.maxFinite,
                  height: 353,
                  child: TabBarView(
                      controller: _tabController,
                      children: [UserPost(), UserPost()]),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
