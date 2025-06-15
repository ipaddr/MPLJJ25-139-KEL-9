// lib/models/edukasi_content.dart
class EdukasiContent {
  final String id; // ID unik untuk konten
  final String type; // Misalnya 'Video' atau 'Artikel'
  final String title;
  final String
  duration; // Durasi untuk video, estimasi waktu baca untuk artikel
  final String views;
  final String imageUrl; // URL gambar thumbnail
  final String fullContent; // Konten lengkap artikel/deskripsi video

  EdukasiContent({
    required this.id,
    required this.type,
    required this.title,
    required this.duration,
    required this.views,
    required this.imageUrl,
    required this.fullContent,
  });
}
