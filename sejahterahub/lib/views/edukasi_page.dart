import 'package:flutter/material.dart';

void main() {
  runApp(const SejahteraHubApp());
}

class SejahteraHubApp extends StatelessWidget {
  const SejahteraHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const EdukasiPage(),
    );
  }
}

class EdukasiPage extends StatelessWidget {
  const EdukasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SejahteraHub'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari topik...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('#Kesejahteraan')),
                Chip(label: Text('#UMKM')),
                Chip(label: Text('#Keuangan')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ContentCard(
                    type: 'Video',
                    duration: '12 min',
                    title: 'Cara Memulai Usaha Kecil dengan Modal Minim',
                    views: '1.2K views',
                  ),
                  SizedBox(height: 16),
                  ContentCard(
                    type: 'Artikel',
                    duration: '5 min',
                    title: 'Panduan Mengelola Keuangan Keluarga',
                    views: '856 views',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Jelajah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class ContentCard extends StatelessWidget {
  final String type;
  final String duration;
  final String title;
  final String views;

  const ContentCard({
    super.key,
    required this.type,
    required this.duration,
    required this.title,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(child: Text('Thumbnail Image')),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$type • $duration',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(views, style: const TextStyle(color: Colors.grey)),
                    const Icon(Icons.bookmark_border),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
