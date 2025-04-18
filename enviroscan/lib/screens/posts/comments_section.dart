import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviroscan/api/apis.dart';

class CommentsSection extends StatefulWidget {
  final String postId;

  const CommentsSection({super.key, required this.postId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _controller = TextEditingController();
  bool _showComments = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(_showComments ? Icons.comment : Icons.comment_outlined),
          onPressed: () => setState(() => _showComments = !_showComments),
        ),
        if (_showComments) ...[
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postId)
                .collection('comments')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final comment = snapshot.data!.docs[index];
                  return ListTile(
                    title: Text(comment['text']),
                    subtitle: Text(comment['username'] ?? 'Anonymous'),
                  );
                },
              );
            },
          ),
          Padding(
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
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    
                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postId)
                        .collection('comments')
                        .add({
                      'text': text,
                      'userId': APIS.auth.currentUser!.uid,
                      'username': APIS.auth.currentUser!.displayName ?? 'Anonymous',
                      'timestamp': Timestamp.now(),
                    });
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}