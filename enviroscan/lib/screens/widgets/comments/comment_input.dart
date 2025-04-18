import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviroscan/api/apis.dart';

class CommentInput extends StatefulWidget {
  final String postId;

  const CommentInput({super.key, required this.postId});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitComment,
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    final user = APIS.auth.currentUser;
    final text = _controller.text.trim();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to comment')),
      );
      return;
    }

    if (text.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'text': text,
        'userId': user.uid,
        'username': user.displayName ?? 'Anonymous',
        'timestamp': Timestamp.now(),
      });
      _controller.clear();
    } catch (e) {
      debugPrint('Error posting comment: $e');
    }
  }
}