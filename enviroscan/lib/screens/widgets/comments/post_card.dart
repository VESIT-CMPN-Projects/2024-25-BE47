import 'package:enviroscan/screens/widgets/comments/comment_input.dart';
import 'package:enviroscan/screens/widgets/comments/comment_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviroscan/screens/home_screen.dart';

class PostCard extends StatefulWidget {
  final QueryDocumentSnapshot post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showComments = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final location = post['location'];
    double latitude = 0.0, longitude = 0.0;

    if (location is GeoPoint) {
      latitude = location.latitude;
      longitude = location.longitude;
    } else if (location is List && location.length == 2) {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              post['imageUrl'],
              width: double.infinity,
              height: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['caption']),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    Text('${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}'),
                  ],
                ),
                const SizedBox(height: 8),
                _buildCommentSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(_showComments 
                  ? Icons.comment 
                  : Icons.comment_outlined),
              onPressed: () => setState(() => _showComments = !_showComments),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.post.id)
                  .collection('comments')
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Text('$count comments');
              },
            ),
          ],
        ),
        if (_showComments) ...[
          CommentList(postId: widget.post.id),
          CommentInput(postId: widget.post.id),
        ],
      ],
    );
  }
}