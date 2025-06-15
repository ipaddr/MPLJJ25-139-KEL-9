// lib/views/create_discussion_page.dart
import 'package:flutter/material.dart';
import 'package:sejahterahub/models/forum_diskusi.dart'; // Import model diskusi

class CreateDiscussionPage extends StatefulWidget {
  const CreateDiscussionPage({super.key});

  @override
  State<CreateDiscussionPage> createState() => _CreateDiscussionPageState();
}

class _CreateDiscussionPageState extends State<CreateDiscussionPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _submitDiscussion() {
    final String title = _titleController.text.trim();
    // Isi konten diskusi dari _contentController.text, tapi tidak dikembalikan ke ForumPage untuk saat ini
    // karena ForumCard tidak menampilkannya secara langsung. Ini akan penting nanti jika ada halaman detail diskusi.

    if (title.isEmpty) {
      // Hanya validasi judul untuk demo ini
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul diskusi tidak boleh kosong.')),
      );
      return;
    }

    // Buat objek ForumDiscussion baru
    final newDiscussion = ForumDiscussion(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID unik sederhana
      title: title,
      author: 'Pengguna Baru', // Placeholder, nanti dari data user login
      timeAgo: 'Baru saja', // Placeholder
      tags: [], // Bisa ditambahkan fitur input tag nanti
      comments: 0,
      likes: 0,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Diskusi "$title" berhasil dibuat (simulasi)!')),
    );

    // Kembali ke halaman forum dan kirim objek diskusi baru
    Navigator.pop(context, newDiscussion);
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
                onPressed: _submitDiscussion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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
