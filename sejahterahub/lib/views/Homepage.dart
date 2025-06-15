// lib/views/Homepage.dart
import 'package:flutter/material.dart';
import 'edukasi/edukasi_page.dart';
import 'forum/forum_page.dart';
import 'profil_page.dart';

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

  // Modifikasi _newsCard untuk menggunakan Image.network
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
            // Ganti Center dengan Image.network
            height: 100,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            clipBehavior:
                Clip.antiAlias, // Penting agar gambar tidak keluar dari border radius
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
                // Warna background jika gambar tidak ada atau error
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior:
                  Clip.antiAlias, // Penting agar gambar tidak keluar dari border radius
              child: Image.network(
                'https://picsum.photos/seed/kesejahteraan/800/400', // URL ilustrasi
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
                  _menuButton(Icons.credit_card, "Daftar Kartu", () {
                    Navigator.pushNamed(context, '/register');
                  }),
                  _menuButton(Icons.search, "Lacak Status", () {
                    Navigator.pushNamed(context, '/track_status');
                  }),
                  _menuButton(Icons.chat_bubble_outline, "Konsultasi", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForumPage(),
                      ),
                    );
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
                child: ListView(
                  children: [
                    const Text(
                      "Berita & Pengumuman Terbaru",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Panggil _newsCard dengan URL gambar
                    _newsCard(
                      "Program Bantuan UMKM 2025",
                      "21 Apr 2025",
                      'https://picsum.photos/seed/umkm/400/200', // URL gambar berita 1
                    ),
                    const SizedBox(height: 12),
                    _newsCard(
                      "Pendaftaran Kartu Prakerja",
                      "20 Apr 2025",
                      'https://picsum.photos/seed/prakerja/400/200', // URL gambar berita 2
                    ),
                    const SizedBox(height: 12),
                    _newsCard(
                      "Update Kebijakan Kesejahteraan Sosial",
                      "19 Apr 2025",
                      'https://picsum.photos/seed/kesejahteraan_berita/400/200', // URL gambar berita 3
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
