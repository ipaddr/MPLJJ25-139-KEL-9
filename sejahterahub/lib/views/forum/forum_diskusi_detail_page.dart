// lib/views/forum/forum_diskusi_detail_page.dart
import 'package:flutter/material.dart';
import 'package:sejahterahub/models/forum_diskusi.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:timeago/timeago.dart' as timeago; // Import timeago

class ForumDiscussionDetailPage extends StatefulWidget {
  final ForumDiscussion discussion;

  const ForumDiscussionDetailPage({super.key, required this.discussion});

  @override
  State<ForumDiscussionDetailPage> createState() =>
      _ForumDiscussionDetailPageState();
}

class _ForumDiscussionDetailPageState extends State<ForumDiscussionDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  // _comments akan diambil dari StreamBuilder, tidak perlu state lokal ini
  // final List<Map<String, String>> _comments = [];

  bool _isAddingComment = false; // State untuk loading saat menambah komentar

  // Stream untuk mendapatkan komentar dari subkoleksi
  Stream<List<Map<String, dynamic>>> _getCommentsStream() {
    return FirebaseFirestore.instance
        .collection('discussions')
        .doc(widget.discussion.id)
        .collection('comments')
        .orderBy('createdAt', descending: false) // Urutkan dari yang terlama
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  Future<void> _addComment() async {
    final String commentText = _commentController.text.trim();

    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar tidak boleh kosong.')),
      );
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk berkomentar.')),
      );
      return;
    }

    setState(() {
      _isAddingComment = true; // Set loading
    });

    try {
      final String authorName =
          currentUser.displayName ?? currentUser.email ?? currentUser.uid;

      // Gunakan Transaction untuk update yang atomik
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. Tambahkan komentar ke subkoleksi
        final commentRef =
            FirebaseFirestore.instance
                .collection('discussions')
                .doc(widget.discussion.id)
                .collection('comments')
                .doc(); // Firestore akan membuat ID dokumen otomatis

        transaction.set(commentRef, {
          'authorId': currentUser.uid,
          'authorName': authorName,
          'text': commentText,
          'createdAt': Timestamp.now(),
        });

        // 2. Perbarui commentsCount di dokumen diskusi induk
        final discussionRef = FirebaseFirestore.instance
            .collection('discussions')
            .doc(widget.discussion.id);

        final discussionSnapshot = await transaction.get(discussionRef);
        final currentCommentsCount =
            (discussionSnapshot.data()?['commentsCount'] as num?)?.toInt() ?? 0;

        transaction.update(discussionRef, {
          'commentsCount': currentCommentsCount + 1,
        });
      });

      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar berhasil ditambahkan!')),
      );
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan komentar: $e')));
    } finally {
      setState(() {
        _isAddingComment = false; // Selesai loading
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format waktu menggunakan timeago
    final String timeAgoText = timeago.format(
      widget.discussion.createdAt.toDate(),
      locale: 'id',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Diskusi')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Diskusi
                  Text(
                    widget.discussion.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Info Penulis
                  Row(
                    children: [
                      Icon(
                        widget.discussion.avatar,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.discussion.authorName} • $timeAgoText', // Gunakan authorName dan timeAgo
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tags
                  Wrap(
                    spacing: 8,
                    children:
                        widget.discussion.tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                backgroundColor: const Color(0xFFE0E0E0),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                  ),
                  const Divider(height: 32),
                  // Isi Diskusi (sekarang diambil dari model)
                  Text(
                    widget.discussion.content, // <--- Ambil dari model
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  // Bagian Komentar
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _getCommentsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading comments: ${snapshot.error}',
                          ),
                        );
                      }
                      final comments = snapshot.data ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Komentar (${comments.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (comments.isEmpty)
                            const Text('Belum ada komentar.'),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              final String commentTimeAgo = timeago.format(
                                (comment['createdAt'] as Timestamp).toDate(),
                                locale: 'id',
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      radius: 16,
                                      child: Icon(Icons.person),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment['authorName'] ?? 'Anonim',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(comment['text'] ?? ''),
                                          Text(
                                            commentTimeAgo,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Input Komentar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar Anda...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isAddingComment
                    ? const CircularProgressIndicator()
                    : IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.blue,
                      onPressed: _addComment,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
