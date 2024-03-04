import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milktea/addImage.dart';

class profilePage extends StatefulWidget {
  const profilePage({super.key});
  @override
  State<profilePage> createState() => _profilePage();
}

final user = FirebaseAuth.instance.currentUser;

class _profilePage extends State<profilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'PROFILE',
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 226, 145),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(children: [
            Text(
              '${user!.email}',
              style: TextStyle(
                fontSize: 18, //
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => addImage()));
              },
              icon: Icon(Icons.edit),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 226, 145)),
            )
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => addImage()));
        },
        label: Icon(Icons.add_photo_alternate),
        backgroundColor: Color.fromARGB(255, 255, 226, 145),
      ),
    );
  }
}
