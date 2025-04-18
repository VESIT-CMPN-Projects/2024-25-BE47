import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviroscan/screens/posts/post_creation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:enviroscan/api/apis.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ImagePicker _imagePicker = ImagePicker();

  final List<Widget> _pages = [
    ComplaintsSection(),
    EventsSection(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Stream<QuerySnapshot> getPostsByType(String postType) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('type', isEqualTo: postType) // Filter posts by type
        .snapshots(); // Listen for real-time updates
  }

  Future<void> _createPost() async {
    final imageSource = await _showImageSourceDialog();
    if (imageSource == null) return;

    final pickedFile = await _pickImage(imageSource);
    if (pickedFile == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostCreationScreen(
          imagePath: pickedFile.path,
          postType: _selectedIndex == 0 ? 'Complaints' : 'Events',
        ),
      ),
    );

    if (result != null) {
      log('Post Created: $result');
      // Handle Firebase upload here if necessary
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(context: context, builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Take a Picture'),
            onTap: () {
              Navigator.pop(context, ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Select from Gallery'),
            onTap: () {
              Navigator.pop(context, ImageSource.gallery);
            },
          ),
        ],
      );
    });
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      return pickedFile;
    } catch (e) {
      log('Image picking failed: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('EnviroScan'),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () {
        // Handle logout logic here
        // Call the logout function
        APIS.logout(context);
      },
    ),
  ],
),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        children: [
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.report_problem),
                label: 'Complaints',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'Events',
              ),
            ],
          ),
          Positioned(
            bottom: 3, // Adjust this value to move the button vertically
            child: FloatingActionButton(
              onPressed: _createPost,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class ComplaintsSection extends StatelessWidget {
  final Stream<QuerySnapshot> postsStream = FirebaseFirestore.instance
      .collection('posts')
      .where('type', isEqualTo: 'Complaints')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: postsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading posts'));
        }

        final posts = snapshot.data!.docs;

        if (posts.isEmpty) {
          return const Center(child: Text('No complaints posted yet.'));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            var location = post['location']; // This could be either a GeoPoint or List
            double latitude = 0.0;
            double longitude = 0.0;

            // If location is a GeoPoint (future posts may be saved this way)
            if (location is GeoPoint) {
              latitude = location.latitude;
              longitude = location.longitude;
            }
            // If location is a list of coordinates (existing posts with the old structure)
            else if (location is List && location.length == 2) {
              latitude = location[0];
              longitude = location[1];
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Display image as usual
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      post['imageUrl'],
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Caption
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      post['caption'] ?? 'No caption',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location (Latitude and Longitude or resolved address)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red),
                        SizedBox(width: 5),
                        Text(
                          '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Optional: Show map preview or interactive map (Google Maps API)
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class EventsSection extends StatelessWidget {
  Stream<QuerySnapshot> getPostsByType(String postType) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('type', isEqualTo: postType)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getPostsByType('Events'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading posts'));
        }

        final posts = snapshot.data!.docs;

        if (posts.isEmpty) {
          return const Center(child: Text('No events posted yet.'));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Image with fixed aspect ratio (Instagram-like)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      post['imageUrl'],
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Caption
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      post['caption'] ?? 'No caption',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Time or Date (Optional)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      post['createdAt'].toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
