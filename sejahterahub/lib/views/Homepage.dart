// lib/views/homepage.dart
import 'package:flutter/material.dart';
import 'package:sejahterahub/views/edukasi/edukasi_page.dart';
import 'package:sejahterahub/views/forum/forum_page.dart';
import 'package:sejahterahub/views/profil_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Import ini
import 'package:sejahterahub/models/edukasi_content.dart'; // <-- Import model ini
import 'package:intl/intl.dart'; // Import untuk format tanggal, pastikan ada di pubspec.yaml

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    EdukasiPage(),
    ForumPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Edukasi'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// lib/views/homepage.dart
// ... (imports dan kelas HomePage tetap sama)

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  static Widget _menuButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  static Widget _newsCard(String title, String date, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: const Center(child: Text("Gagal memuat gambar")),
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(date, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 150, 243),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.8 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "SejahteraHub",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Membangun Kesejahteraan Bersama"),
                      ],
                    ),
                  ),
                  const Icon(Icons.notifications_none),
                ],
              ),
            ),
            Container(
              height: 140,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                'https://picsum.photos/seed/kesejahteraan/800/400',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 140,
                      color: Colors.white.withOpacity(0.3),
                      child: const Center(
                        child: Text(
                          "Gagal memuat ilustrasi",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _menuButton(Icons.description, "Daftar Pengajuan", () {
                    Navigator.pushNamed(context, '/submit_application');
                  }),
                  _menuButton(Icons.search, "Lacak Status", () {
                    Navigator.pushNamed(context, '/tracking');
                  }),
                  _menuButton(Icons.chat_bubble_outline, "Konsultasi", () {
                    Navigator.pushNamed(context, '/chatbot');
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Berita & Pengumuman Terbaru",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('articles')
                                .orderBy('lastUpdated', descending: true)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text('Tidak ada berita terbaru.'),
                            );
                          }

                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final doc = snapshot.data!.docs[index];
                              // Pastikan Anda mendapatkan data map dari dokumen
                              final data =
                                  doc.data()
                                      as Map<
                                        String,
                                        dynamic
                                      >?; // <-- Lakukan cast ke Map<String, dynamic>?

                              // Lakukan null-check pada 'data' sebelum mengaksesnya
                              if (data == null) {
                                return const SizedBox.shrink(); // Atau tampilkan placeholder error
                              }

                              final article = EdukasiContent(
                                id: doc.id,
                                type: data['type'] ?? 'Artikel',
                                title: data['title'] ?? 'Tanpa Judul',
                                duration: data['duration'] ?? 'N/A',
                                views: data['views'] ?? '0 views',
                                imageUrl: data['imageUrl'] ?? '',
                                fullContent: data['fullContent'] ?? '',
                                tags: List<String>.from(data['tags'] ?? []),
                              );

                              String date = 'N/A';
                              // Gunakan data map yang sudah di-null-check
                              if (data.containsKey('lastUpdated') &&
                                  data['lastUpdated'] is Timestamp) {
                                date = DateFormat(
                                  'dd MMM yyyy', // Format tanggal yang lebih jelas
                                ).format(
                                  (data['lastUpdated'] as Timestamp).toDate(),
                                );
                              } else if (data.containsKey('createdAt') &&
                                  data['createdAt'] is Timestamp) {
                                date = DateFormat(
                                  'dd MMM yyyy', // Format tanggal yang lebih jelas
                                ).format(
                                  (data['createdAt'] as Timestamp).toDate(),
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _newsCard(
                                  article.title,
                                  date,
                                  article.imageUrl,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
