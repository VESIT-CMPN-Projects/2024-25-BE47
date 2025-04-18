import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviroscan/screens/posts/comments_section.dart';
import 'package:flutter/material.dart';

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
                      width: double.infinity, // Takes up full width of the container
                      height: MediaQuery.of(context).size.width, // Square-like aspect
                      fit: BoxFit.cover, // Ensures image fills the space correctly
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
                  CommentsSection(postId: post.id),
                ],
              ),
            );
          },
        );
      },
    );
  }
}