import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final Map<String, dynamic> comment;

  const Comment({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.person, size: 24),
      title: Text(comment['text']),
      subtitle: Text(comment['username'] ?? 'Anonymous'),
    );
  }
}