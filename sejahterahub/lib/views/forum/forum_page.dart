// lib/views/ForumPage.dart
import 'package:flutter/material.dart';
import 'package:sejahterahub/models/forum_diskusi.dart';
import 'package:sejahterahub/views/forum/create_diskusi_page.dart';
import 'package:sejahterahub/views/forum/forum_diskusi_detail_page.dart'; // Import halaman buat diskusi
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:timeago/timeago.dart' as timeago; // Import timeago

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _searchController = TextEditingController();
  // Tidak perlu _allDiscussions dan _filteredDiscussions lagi secara lokal,
  // karena kita akan streaming langsung dari Firestore.

  // Stream untuk mendapatkan daftar diskusi dari Firestore
  Stream<List<ForumDiscussion>> _getDiscussionsStream() {
    return FirebaseFirestore.instance
        .collection('discussions')
        .orderBy('createdAt', descending: true) // Urutkan dari yang terbaru
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ForumDiscussion.fromFirestore(doc))
              .toList();
        });
  }

  @override
  void initState() {
    super.initState();
    // Inisialisasi locale timeago ke bahasa Indonesia
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }

  // Fungsi filter akan bekerja pada data yang sudah di-fetch
  // Jika ingin real-time search langsung di Firestore, akan butuh indeks dan query yang lebih kompleks.
  // Untuk saat ini, kita akan memfilter di sisi klien setelah data di-fetch.
  List<ForumDiscussion> _filterDiscussionsLocally(
    List<ForumDiscussion> allDiscussions,
    String query,
  ) {
    if (query.isEmpty) {
      return allDiscussions;
    }
    return allDiscussions.where((discussion) {
      return discussion.title.toLowerCase().contains(query.toLowerCase()) ||
          discussion.authorName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Forum Komunitas',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search & Notification Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      setState(() {
                        // Memicu rebuild untuk memfilter tampilan
                        // Data utama tetap di stream builder
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari topik diskusi...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.notifications_none), // Ini masih placeholder
              ],
            ),

            const SizedBox(height: 16),

            // Button Buat Diskusi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.add),
                label: const Text("Buat Diskusi Baru"),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateDiscussionPage(),
                    ),
                  );
                  // Tidak perlu _addDiscussion lagi karena StreamBuilder akan otomatis update
                },
              ),
            ),

            const SizedBox(height: 16),

            // List diskusi dari Firestore
            Expanded(
              child: StreamBuilder<List<ForumDiscussion>>(
                stream: _getDiscussionsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Belum ada diskusi. Mulai yang pertama!'),
                    );
                  }

                  // Lakukan filtering lokal setelah data di-fetch
                  final filteredDiscussions = _filterDiscussionsLocally(
                    snapshot.data!,
                    _searchController.text,
                  );

                  if (filteredDiscussions.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada diskusi yang cocok dengan pencarian Anda.',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredDiscussions.length,
                    itemBuilder: (context, index) {
                      final discussion = filteredDiscussions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ForumCard(discussion: discussion),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForumCard extends StatelessWidget {
  final ForumDiscussion discussion;

  const ForumCard({super.key, required this.discussion});

  @override
  Widget build(BuildContext context) {
    // Format waktu menggunakan timeago
    final String timeAgoText = timeago.format(
      discussion.createdAt.toDate(),
      locale: 'id',
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ForumDiscussionDetailPage(discussion: discussion),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul dan Penulis
            Row(
              children: [
                Icon(discussion.avatar, size: 40),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discussion.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${discussion.authorName} • $timeAgoText", // Gunakan authorName dan timeAgo
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tags
            Wrap(
              spacing: 8,
              children:
                  discussion.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: const Color(0xFFE0E0E0),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 8),

            // Komentar dan Suka
            Row(
              children: [
                const Icon(Icons.comment, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${discussion.commentsCount}'), // Gunakan commentsCount
                const SizedBox(width: 16),
                const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${discussion.likes}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
