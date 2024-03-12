import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class forgotPasswordPage extends StatefulWidget {
  const forgotPasswordPage({super.key});

  @override
  State<forgotPasswordPage> createState() => _forgotPasswordPageState();
}

class _forgotPasswordPageState extends State<forgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Forgot Password', style: TextStyle(color: Colors.black)),
        ),
        backgroundColor: Color.fromARGB(255, 255, 226, 145),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter your email to get a password reset link',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  labelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold // ขนาดข้อความ Label Text
                      ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your email';
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  passwordReset();
                },
                child: Text(
                  'Reset Password',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 226, 145)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
