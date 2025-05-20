import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

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
                onPressed: () {
                  // Aksi buat diskusi
                },
              ),
            ),

            const SizedBox(height: 16),

            // List diskusi
            Expanded(
              child: ListView(
                children: const [
                  ForumCard(
                    avatar: Icons.account_circle,
                    title: "Tips Mengembangkan UMKM di Era Digital",
                    author: "Budi Santoso",
                    timeAgo: "2 jam yang lalu",
                    tags: ["#UsahaKecil", "#TipsKeuangan"],
                    comments: 24,
                    likes: 56,
                  ),
                  SizedBox(height: 12),
                  ForumCard(
                    avatar: Icons.account_circle,
                    title: "Info Bantuan BPUM 2025",
                    author: "Siti Aminah",
                    timeAgo: "5 jam yang lalu",
                    tags: ["#BantuanSosial"],
                    comments: 42,
                    likes: 89,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForumCard extends StatelessWidget {
  final IconData avatar;
  final String title;
  final String author;
  final String timeAgo;
  final List<String> tags;
  final int comments;
  final int likes;

  const ForumCard({
    super.key,
    required this.avatar,
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.tags,
    required this.comments,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul dan Avatar
          Row(
            children: [
              Icon(avatar, size: 40),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "$author • $timeAgo",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                tags
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
              Text('$comments'),
              const SizedBox(width: 16),
              const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('$likes'),
            ],
          ),
        ],
      ),
    );
  }
}
