import 'package:flutter/material.dart';
import 'package:sejahterahub/models/forum_diskusi.dart';

class ForumDiscussionDetailPage extends StatefulWidget {
  final ForumDiscussion discussion;

  const ForumDiscussionDetailPage({super.key, required this.discussion});

  @override
  State<ForumDiscussionDetailPage> createState() =>
      _ForumDiscussionDetailPageState();
}

class _ForumDiscussionDetailPageState extends State<ForumDiscussionDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  // UBAH BAGIAN INI: Inisialisasi _comments menjadi kosong
  final List<Map<String, String>> _comments = []; // <-- Ubah dari sini

  void _addComment() {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar tidak boleh kosong.')),
      );
      return;
    }

    setState(() {
      _comments.add({
        'author': 'Anda', // Placeholder, nanti dari data user login
        'text': _commentController.text.trim(),
      });
      _commentController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Komentar berhasil ditambahkan (simulasi)!'),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        '${widget.discussion.author} • ${widget.discussion.timeAgo}',
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
                  // Isi Diskusi (Placeholder)
                  const Text(
                    'Ini adalah isi lengkap dari diskusi. Di sini Anda bisa menuliskan pertanyaan, pengalaman, atau topik yang ingin dibahas lebih lanjut. Untuk saat ini, konten diskusi ini masih placeholder. Nantinya, konten ini akan diambil dari Firebase.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Komentar (${_comments.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Daftar Komentar
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment['author']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(comment['text']!),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                IconButton(
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
