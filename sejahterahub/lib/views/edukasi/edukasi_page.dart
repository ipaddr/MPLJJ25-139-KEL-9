// lib/views/edukasi_page.dart
import 'package:flutter/material.dart';
import 'package:sejahterahub/models/edukasi_content.dart'; // Import model
import 'package:sejahterahub/views/edukasi/edukasi_detail_page.dart'; // Import halaman detail

class EdukasiPage extends StatefulWidget {
  // Ubah menjadi StatefulWidget
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  final TextEditingController _searchController = TextEditingController();
  List<EdukasiContent> _allContent = [];
  List<EdukasiContent> _filteredContent = [];

  @override
  void initState() {
    super.initState();
    // Data dummy untuk simulasi. Nanti akan diambil dari Firebase.
    _allContent = [
      EdukasiContent(
        id: '1',
        type: 'Video',
        duration: '12 min',
        title: 'Cara Memulai Usaha Kecil dengan Modal Minim',
        views: '1.2K views',
        imageUrl:
            'https://via.placeholder.com/150/FF5733/FFFFFF?text=UMKM+Video',
        fullContent:
            'Video ini membahas langkah-langkah praktis untuk memulai usaha kecil dengan modal terbatas. Meliputi ide bisnis, strategi pemasaran, dan pengelolaan keuangan sederhana. Pelajari tips dan trik dari para ahli untuk sukses di era digital.',
      ),
      EdukasiContent(
        id: '2',
        type: 'Artikel',
        duration: '5 min',
        title: 'Panduan Mengelola Keuangan Keluarga',
        views: '856 views',
        imageUrl:
            'https://via.placeholder.com/150/33FF57/FFFFFF?text=Keuangan+Artikel',
        fullContent:
            'Artikel ini memberikan panduan lengkap tentang bagaimana keluarga dapat mengelola keuangan mereka dengan lebih baik. Termasuk tips menabung, investasi, dan menghindari utang. Sangat cocok untuk Anda yang ingin mencapai stabilitas finansial.',
      ),
      EdukasiContent(
        id: '3',
        type: 'Video',
        duration: '10 min',
        title: 'Memanfaatkan Kartu Kesejahteraan untuk Kebutuhan Pokok',
        views: '990 views',
        imageUrl:
            'https://via.placeholder.com/150/3366FF/FFFFFF?text=Kesejahteraan+Video',
        fullContent:
            'Video tutorial ini menjelaskan cara efektif menggunakan kartu kesejahteraan untuk memenuhi kebutuhan dasar keluarga Anda. Pahami hak-hak Anda dan manfaatkan program pemerintah dengan bijak.',
      ),
      EdukasiContent(
        id: '4',
        type: 'Artikel',
        duration: '7 min',
        title: 'Peluang Usaha di Sektor Agribisnis',
        views: '720 views',
        imageUrl:
            'https://via.placeholder.com/150/FF33CC/FFFFFF?text=Agribisnis+Artikel',
        fullContent:
            'Jelajahi berbagai peluang usaha menarik di sektor agribisnis yang memiliki potensi pertumbuhan besar. Dari pertanian organik hingga budidaya perikanan, temukan ide yang cocok untuk Anda.',
      ),
    ];
    _filteredContent = _allContent; // Inisialisasi dengan semua konten
  }

  void _filterContent(String query) {
    setState(() {
      _filteredContent =
          _allContent.where((content) {
            return content.title.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

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
              controller: _searchController,
              onChanged: _filterContent, // Panggil filter saat teks berubah
              decoration: InputDecoration(
                hintText: 'Cari topik...',
                prefixIcon: const Icon(Icons.search),
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
              child: ListView.builder(
                itemCount: _filteredContent.length,
                itemBuilder: (context, index) {
                  final content = _filteredContent[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ContentCard(
                      content: content, // Teruskan objek content
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

class ContentCard extends StatelessWidget {
  final EdukasiContent content; // Sekarang menerima objek model

  const ContentCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior:
          Clip.antiAlias, // Penting agar gambar tidak keluar dari border radius
      child: InkWell(
        // Tambahkan InkWell untuk aksi tap
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EdukasiDetailPage(content: content),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.network(
                  content.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(child: Text('Gagal memuat gambar')),
                      ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${content.type} • ${content.duration}',
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
                  Text(
                    content.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        content.views,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Icon(Icons.bookmark_border),
                    ],
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
