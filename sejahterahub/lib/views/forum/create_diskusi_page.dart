// lib/views/create_discussion_page.dart
import 'package:flutter/material.dart';
import 'package:sejahterahub/models/forum_diskusi.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class CreateDiscussionPage extends StatefulWidget {
  const CreateDiscussionPage({super.key});

  @override
  State<CreateDiscussionPage> createState() => _CreateDiscussionPageState();
}

class _CreateDiscussionPageState extends State<CreateDiscussionPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false; // State untuk loading

  Future<void> _submitDiscussion() async {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan isi diskusi tidak boleh kosong.'),
        ),
      );
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk membuat diskusi.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading
    });

    try {
      // Dapatkan nama pengguna dari FirebaseAuth atau Firestore (jika ada profil user)
      // Untuk demo ini, kita gunakan displayName atau email, atau fallback ke UID
      final String authorName =
          currentUser.displayName ?? currentUser.email ?? currentUser.uid;

      // Buat objek ForumDiscussion baru untuk dikirim ke Firestore
      final newDiscussion = ForumDiscussion(
        id: '', // ID akan di-generate oleh Firestore
        title: title,
        content: content,
        authorId: currentUser.uid,
        authorName: authorName,
        createdAt: Timestamp.now(), // Gunakan Timestamp Firestore
        likes: 0,
        commentsCount: 0,
        tags: [],
      );

      // Simpan diskusi ke koleksi 'discussions' di Firestore
      await FirebaseFirestore.instance
          .collection('discussions')
          .add(newDiscussion.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Diskusi "$title" berhasil dibuat!')),
      );

      // Kembali ke halaman forum (tidak perlu mengembalikan objek, karena data akan di-fetch dari Firestore)
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting discussion: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat diskusi: $e')));
    } finally {
      setState(() {
        _isLoading = false; // Selesai loading
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Diskusi Baru'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Diskusi',
                hintText: 'Misalnya: Tips Mengajukan Kartu Kesejahteraan',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Isi Diskusi',
                hintText:
                    'Tuliskan pertanyaan atau topik diskusi Anda di sini...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              minLines: 5,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : _submitDiscussion, // Disable saat loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : const Text(
                          'Kirim Diskusi',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
