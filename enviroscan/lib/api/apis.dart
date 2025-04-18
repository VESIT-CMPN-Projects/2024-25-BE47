import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviroscan/screens/auth/login_screen.dart';
import 'package:enviroscan/screens/question.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:enviroscan/models/users.dart' ;
import 'package:enviroscan/models/events.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class APIS {
  static fb.FirebaseAuth auth = fb.FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static fb.User get user => auth.currentUser!;

  static late User me;

  // Check if the user exists in Firestore
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // Get user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((doc) async {
      if (doc.exists) {
        me = User.fromJson(doc.data()!);
        log('User Data: ${doc.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // Create new user in Firestore
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final userProfile = User(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      role: 'Public',  // Default role
      createdAt: time,
      lastActive: time,
      isOnline: false,
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(userProfile.toJson());
  }

  // Add an event
  static Future<void> addEvent(Event event) async {
    await firestore
        .collection('events')
        .doc(event.eventId)
        .set(event.toJson());
  }

  // Get all events
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllEvents() {
    return firestore.collection('events').snapshots();
  }

  // Register user for an event
  static Future<void> registerForEvent(String eventId) async {
    final eventRef = firestore.collection('events').doc(eventId);
    await eventRef.update({
      'participants': FieldValue.arrayUnion([user.uid])
    });
  }


static Future<void> logout(BuildContext context) async {
  try {
    // Sign out from Google
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    // Sign out from Firebase
    await auth.signOut();

    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const UserTypeSelectionScreen()), // Replace with your login screen route
    );
  } catch (e) {
    // Handle errors during logout
    log('Error logging out: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error logging out. Please try again.')),
    );
  }
}
static Future<void> savePost({
  required String type,
  required String caption,
  required String imageUrl,
  required GeoPoint location,
}) async {
  try {
    // Generate a new post ID
    final postId = firestore.collection('posts').doc().id;

    // Create the post object
    final post = {
      'id': postId,
      'type': type,
      'caption': caption,
      'imageUrl': imageUrl,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(), // Server-side timestamp
      'userId': user.uid,
    };

    // Save the post to Firestore
    await firestore.collection('posts').doc(postId).set(post);

    log('Post created successfully with ID: $postId');
  } catch (e) {
    log('Error saving post: $e');
    throw e; // Rethrow error to handle it in UI
  }
}



static Future<String> uploadImage(File image) async {
  final storageRef = FirebaseStorage.instance.ref();
  final imageRef = storageRef.child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
  try {
    final uploadTask = await imageRef.putFile(image);
    log('Upload complete: ${uploadTask.state}');
    
    // Log the download URL to ensure it is being retrieved
    final imageUrl = await imageRef.getDownloadURL();
    log('Image URL: $imageUrl');
    return imageUrl;
  } catch (e) {
    log('Error uploading image: $e');
    rethrow; // Re-throw the error for further handling
  }
}





}
