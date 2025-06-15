// lib/models/submission.dart
import 'package:flutter/material.dart'; // Untuk Icons.check_circle, dll.

class Submission {
  final String id;
  final String cardType; // Contoh: 'Kartu Kesejahteraan', 'Bantuan UMKM'
  final DateTime submissionDate;
  final String status; // Contoh: 'Sedang Diproses', 'Disetujui', 'Ditolak'
  final String? notes; // Catatan tambahan
  final String? approvalDate; // Tanggal disetujui/ditolak

  Submission({
    required this.id,
    required this.cardType,
    required this.submissionDate,
    required this.status,
    this.notes,
    this.approvalDate,
  });

  // Helper untuk mendapatkan warna status
  Color get statusColor {
    switch (status) {
      case 'Sedang Diproses':
        return Colors.orange;
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper untuk mendapatkan ikon status
  IconData get statusIcon {
    switch (status) {
      case 'Sedang Diproses':
        return Icons.hourglass_empty;
      case 'Disetujui':
        return Icons.check_circle_outline;
      case 'Ditolak':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
