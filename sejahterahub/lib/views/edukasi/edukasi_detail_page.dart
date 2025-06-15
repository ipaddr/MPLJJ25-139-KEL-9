// lib/views/edukasi_detail_page.dart
import 'package:flutter/material.dart';
import 'package:sejahterahub/models/edukasi_content.dart'; // Import model

class EdukasiDetailPage extends StatelessWidget {
  final EdukasiContent content;

  const EdukasiDetailPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Thumbnail
            Image.network(
              content.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Text('Gagal memuat gambar')),
                  ),
            ),
            const SizedBox(height: 16),

            // Judul Konten
            Text(
              content.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Tipe, Durasi, dan Views
            Row(
              children: [
                Icon(
                  content.type == 'Video'
                      ? Icons.play_circle_fill
                      : Icons.article,
                  size: 18,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 4),
                Text(
                  '${content.type} • ${content.duration}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.visibility, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text(content.views, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 24),

            // Konten Lengkap
            Text(
              content.fullContent,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),

            // Tombol tambahan (misal: "Tonton Video" jika tipe Video)
            if (content.type == 'Video')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Memutar video (simulasi)!'),
                      ),
                    );
                    // Nanti bisa tambahkan fungsionalitas memutar video
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Tonton Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
