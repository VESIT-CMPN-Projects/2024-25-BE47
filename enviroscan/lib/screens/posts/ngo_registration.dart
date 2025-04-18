import 'package:enviroscan/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NgoAuthScreen extends StatefulWidget {
  @override
  _NgoAuthScreenState createState() => _NgoAuthScreenState();
}

class _NgoAuthScreenState extends State<NgoAuthScreen> {
  bool isRegistering = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController regNumberController = TextEditingController();
  String? documentUrl;

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> registerNgo() async {
    final userCredential = await signInWithGoogle();
    if (userCredential == null) return;

    final user = userCredential.user;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('ngos').doc(user.uid).set({
      'name': nameController.text,
      'email': user.email,
      'registrationNumber': regNumberController.text,
      'documentUrl': documentUrl ?? '',
      'isVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  Future<void> loginNgo() async {
    final userCredential = await signInWithGoogle();
    if (userCredential == null) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NGO Authentication")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [isRegistering, !isRegistering],
              onPressed: (index) {
                setState(() {
                  isRegistering = index == 0;
                });
              },
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: Colors.green,
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text("Register")),
                Padding(padding: EdgeInsets.all(8.0), child: Text("Login")),
              ],
            ),
            SizedBox(height: 20),
            if (isRegistering) ...[
              TextField(controller: nameController, decoration: InputDecoration(labelText: "NGO Name")),
              TextField(controller: regNumberController, decoration: InputDecoration(labelText: "Registration Number")),
              ElevatedButton(onPressed: registerNgo, child: Text("Register with Google")),
            ] else ...[
              ElevatedButton(onPressed: loginNgo, child: Text("Login with Google")),
            ],
          ],
        ),
      ),
    );
  }
}
