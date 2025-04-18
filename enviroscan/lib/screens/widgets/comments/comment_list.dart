import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'comment.dart';

class CommentList extends StatelessWidget {
  final String postId;

  const CommentList({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final comments = snapshot.data!.docs;
        return Column(
          children: comments.map((doc) {
            return Comment(comment: doc.data() as Map<String, dynamic>);
          }).toList(),
        );
      },
    );
  }
}