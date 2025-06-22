// lib/models/forum_diskusi.dart
import 'package:flutter/material.dart'; // Untuk IconData
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Timestamp

class ForumDiscussion {
  final String id;
  final String title;
  final String content; // Tambahkan ini untuk isi diskusi
  final String authorId; // Tambahkan ini untuk ID pengguna pembuat
  final String authorName; // Tambahkan ini untuk nama pengguna pembuat
  final Timestamp createdAt; // Tambahkan ini untuk waktu pembuatan
  final int likes;
  final int commentsCount; // Ubah dari 'comments' menjadi 'commentsCount'
  final List<String> tags;

  // IconData untuk avatar, tidak disimpan di Firestore
  final IconData avatar = Icons.person_pin; // Default avatar

  ForumDiscussion({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.likes = 0, // Default nilai
    this.commentsCount = 0, // Default nilai
    this.tags = const [], // Default nilai
  });

  // Factory constructor untuk membuat objek ForumDiscussion dari Firestore DocumentSnapshot
  factory ForumDiscussion.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ForumDiscussion(
      id: doc.id,
      title: data['title'] as String,
      content: data['content'] as String,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      createdAt: data['createdAt'] as Timestamp,
      likes: (data['likes'] as num?)?.toInt() ?? 0, // Konversi num ke int
      commentsCount:
          (data['commentsCount'] as num?)?.toInt() ?? 0, // Konversi num ke int
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  // Method untuk mengubah objek ForumDiscussion menjadi Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
      'likes': likes,
      'commentsCount': commentsCount,
      'tags': tags,
    };
  }
}
