// lib/models/submission.dart
import 'package:flutter/material.dart';

class Submission {
  final String id;
  final String cardType;
  final DateTime submissionDate;
  final String status;
  final String? notes;
  final String? approvalDate; // ini masih String, bisa diubah ke DateTime nanti
  final String userId; // Penting untuk melacak pengajuan user

  // Tambahkan URL dokumen agar bisa dibuka dari lacak status
  final String? ktpDocUrl;
  final String? kkDocUrl;
  final String? businessDocUrl;

  Submission({
    required this.id,
    required this.cardType,
    required this.submissionDate,
    required this.status,
    this.notes,
    this.approvalDate,
    required this.userId,
    this.ktpDocUrl,
    this.kkDocUrl,
    this.businessDocUrl,
  });

  // Helper untuk mendapatkan warna status (sesuai VerificationPage)
  Color get statusColor {
    switch (status) {
      case 'Menunggu Verifikasi':
        return Colors.orange[100]!;
      case 'Sedang Diproses':
        return Colors.blue[100]!;
      case 'Disetujui':
        return Colors.green[100]!;
      case 'Ditolak':
        return Colors.red[100]!;
      case 'Minta Revisi':
        return Colors.purple[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  // Helper untuk mendapatkan warna teks status (sesuai VerificationPage)
  Color get statusTextColor {
    switch (status) {
      case 'Menunggu Verifikasi':
        return Colors.orange;
      case 'Sedang Diproses':
        return Colors.blue;
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      case 'Minta Revisi':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Helper untuk mendapatkan ikon status (opsional)
  IconData get statusIcon {
    switch (status) {
      case 'Menunggu Verifikasi':
        return Icons.hourglass_empty;
      case 'Sedang Diproses':
        return Icons.pending_actions;
      case 'Disetujui':
        return Icons.check_circle_outline;
      case 'Ditolak':
        return Icons.cancel_outlined;
      case 'Minta Revisi':
        return Icons.lightbulb_outline; // Atau ikon lain yang sesuai
      default:
        return Icons.info_outline;
    }
  }
}
