// lib/views/ForumPage.dart
import 'package:flutter/material.dart';
import 'package:sejahterahub/models/forum_diskusi.dart';
import 'package:sejahterahub/views/forum/forum_diskusi_detail_page.dart'; // <-- Import halaman detail baru

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ForumDiscussion> _allDiscussions = [];
  List<ForumDiscussion> _filteredDiscussions = [];

  @override
  void initState() {
    super.initState();
    _allDiscussions = [
      ForumDiscussion(
        id: 'd1',
        title: "Tips Mengembangkan UMKM di Era Digital",
        author: "Budi Santoso",
        timeAgo: "2 jam yang lalu",
        tags: ["#UsahaKecil", "#TipsKeuangan"],
        comments: 24,
        likes: 56,
      ),
      ForumDiscussion(
        id: 'd2',
        title: "Info Bantuan BPUM 2025",
        author: "Siti Aminah",
        timeAgo: "5 jam yang lalu",
        tags: ["#BantuanSosial"],
        comments: 42,
        likes: 89,
      ),
      ForumDiscussion(
        id: 'd3',
        title: "Bagaimana Cara Mengajukan KUR?",
        author: "Joko Susilo",
        timeAgo: "1 hari yang lalu",
        tags: ["#UMKM", "#Pinjaman"],
        comments: 15,
        likes: 30,
      ),
    ];
    _filteredDiscussions = _allDiscussions;
  }

  void _filterDiscussions(String query) {
    setState(() {
      _filteredDiscussions =
          _allDiscussions.where((discussion) {
            return discussion.title.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                discussion.author.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  void _addDiscussion(ForumDiscussion newDiscussion) {
    setState(() {
      _allDiscussions.insert(0, newDiscussion);
      _filteredDiscussions = _allDiscussions;
      _searchController.clear();
    });
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
                    onChanged: _filterDiscussions,
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
                const Icon(Icons.notifications_none),
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
                  final newDiscussionData = await Navigator.pushNamed(
                    context,
                    '/create_discussion',
                  );
                  if (newDiscussionData != null &&
                      newDiscussionData is ForumDiscussion) {
                    _addDiscussion(newDiscussionData);
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            // List diskusi
            Expanded(
              child: ListView.builder(
                itemCount: _filteredDiscussions.length,
                itemBuilder: (context, index) {
                  final discussion = _filteredDiscussions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ForumCard(
                      discussion: discussion, // <-- Teruskan objek discussion
                    ),
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
  final ForumDiscussion discussion; // Sekarang menerima objek model

  const ForumCard({
    super.key,
    required this.discussion, // Perbarui constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        // <-- Tambahkan InkWell untuk aksi tap
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
            // Judul dan Avatar
            Row(
              children: [
                Icon(discussion.avatar, size: 40), // Gunakan data dari model
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discussion.title, // Gunakan data dari model
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${discussion.author} • ${discussion.timeAgo}", // Gunakan data dari model
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
                  discussion
                      .tags // Gunakan data dari model
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
                Text('${discussion.comments}'), // Gunakan data dari model
                const SizedBox(width: 16),
                const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${discussion.likes}'), // Gunakan data dari model
              ],
            ),
          ],
        ),
      ),
    );
  }
}
