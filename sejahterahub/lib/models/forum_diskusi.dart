// lib/models/forum_discussion.dart
import 'package:flutter/material.dart'; // Diperlukan untuk IconData jika disimpan di model

class ForumDiscussion {
  final String id;
  final String title;
  final String author;
  final String timeAgo; // Untuk simulasi, bisa string saja dulu
  final List<String> tags;
  final int comments;
  final int likes;
  final IconData avatar; // Untuk avatar placeholder

  ForumDiscussion({
    required this.id,
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.tags,
    this.comments = 0,
    this.likes = 0,
    this.avatar = Icons.account_circle, // Default avatar
  });
}
