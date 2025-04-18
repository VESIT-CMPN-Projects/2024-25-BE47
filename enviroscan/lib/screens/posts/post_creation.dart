import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviroscan/api/apis.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PostCreationScreen extends StatefulWidget {
  final String imagePath;
  final String postType; // Automatically passed from the HomeScreen

  const PostCreationScreen({
    Key? key,
    required this.imagePath,
    required this.postType,
  }) : super(key: key);

  @override
  _PostCreationScreenState createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;
  bool _isLocationEnabled = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    if (widget.postType == 'Complaints') {
      _getLocation(); // Request location if the post type is 'Complaints'
    }
  }

  // Request permission and get the current location for complaints
  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return;
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _isLocationEnabled = true; // Location is successfully retrieved
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${widget.postType} Post'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(File(widget.imagePath)), // Display the selected image
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                  labelText: 'Enter a caption',
                ),
                maxLines: null, // Allows multi-line input
              ),
            ),
            if (widget.postType == 'Complaints') 
              _isLocationEnabled
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Location: $_latitude, $_longitude',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _shouldEnableButton() ? _createPost : null,
                    child: const Text('Post'),
                  )
          ],
        ),
      ),
    );
  }

  bool _shouldEnableButton() {
  if (widget.postType == 'Complaints') {
    return _isLocationEnabled;
  }
  return true; // Always enable for Events
  }
  
   
  Future<void> _createPost() async {
    final caption = _captionController.text.trim();
    log('Creating post with caption: $caption');

    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caption cannot be empty')),
      );
      return;
    }

    if (widget.postType == 'Complaints' && (_latitude == null || _longitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location for complaints')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image
      log('Uploading image...');
      final imageUrl = await APIS.uploadImage(File(widget.imagePath));
      log('Image URL: $imageUrl');

      // Save post to Firestore
      log('Saving post to Firestore...');
      await APIS.savePost(
        type: widget.postType,
        caption: caption,
        imageUrl: imageUrl,
        location: widget.postType == 'Complaints'
            ? GeoPoint(_latitude!, _longitude!) // Use geotag if it's a complaint
            : GeoPoint(0.0, 0.0), // Default for events (no location)
      );
      log('Post saved successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );

      Navigator.pop(context); // Navigate back
    } catch (e) {
      log('Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
