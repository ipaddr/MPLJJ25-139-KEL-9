// lib/views/tracking_status_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Import ini
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import ini
import 'package:intl/intl.dart'; // <-- Import ini, pastikan ada di pubspec.yaml
import 'package:url_launcher/url_launcher.dart'; // <-- Import ini, jika akan membuka URL dokumen
import 'package:sejahterahub/models/submission.dart'; // Import model Submission yang sudah ada

class TrackingStatusPage extends StatefulWidget {
  const TrackingStatusPage({super.key});

  @override
  State<TrackingStatusPage> createState() => _TrackingStatusPageState();
}

class _TrackingStatusPageState extends State<TrackingStatusPage> {
  User? _currentUser; // Untuk menyimpan pengguna yang sedang login

  @override
  void initState() {
    super.initState();
    _currentUser =
        FirebaseAuth.instance.currentUser; // Dapatkan pengguna saat ini
  }

  // Fungsi untuk mendapatkan stream pengajuan HANYA untuk pengguna yang sedang login
  Stream<List<Submission>> _getUserSubmissionsStream() {
    if (_currentUser == null) {
      return Stream.value([]); // Jika tidak ada user, kembalikan stream kosong
    }
    return FirebaseFirestore.instance
        .collection('submissions')
        .where(
          'userId',
          isEqualTo: _currentUser!.uid,
        ) // Filter berdasarkan userId
        .orderBy('submissionDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data =
                doc.data(); // Mendapatkan data sebagai Map<String, dynamic>
            return Submission(
              id: doc.id,
              cardType: data['cardType'] ?? 'N/A',
              submissionDate: (data['submissionDate'] as Timestamp).toDate(),
              status: data['status'] ?? 'Menunggu Verifikasi',
              notes: data['notes'],
              approvalDate:
                  data['approvalDate'] != null
                      ? DateFormat(
                        'dd MMM yyyy HH:mm',
                      ).format((data['approvalDate'] as Timestamp).toDate())
                      : null,
              userId: data['userId'] ?? 'unknown',
              ktpDocUrl: data['ktpDocUrl'],
              kkDocUrl: data['kkDocUrl'],
              businessDocUrl: data['businessDocUrl'],
            );
          }).toList();
        });
  }

  // Fungsi untuk membuka URL dokumen (sama seperti di VerificationPage)
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tidak dapat membuka link: $url')));
    }
  }

  // Widget untuk menampilkan detail dokumen di modal (opsional, jika ingin tampilkan lebih detail)
  void _showDocumentDetailModal(String fileName, String url) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fileName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _launchUrl(url);
                  Navigator.pop(context);
                },
                child: const Text('Buka Dokumen'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lacak Status Pengajuan')),
      body:
          _currentUser ==
                  null // Tampilkan pesan jika user belum login
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Anda harus login untuk melacak pengajuan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 30),
                      // Tombol untuk ke halaman login
                    ],
                  ),
                ),
              )
              : StreamBuilder<List<Submission>>(
                // <-- Gunakan StreamBuilder
                stream: _getUserSubmissionsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Anda belum memiliki pengajuan yang sedang diproses.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Silakan ajukan permohonan kartu untuk melihat status di sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/submit_application',
                                );
                              },
                              child: const Text('Ajukan Permohonan Sekarang'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Jika ada data pengajuan
                  List<Submission> submissions = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final submission = submissions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    submission.cardType,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: submission.statusColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          submission.statusIcon,
                                          size: 16,
                                          color: submission.statusTextColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          submission.status,
                                          style: TextStyle(
                                            color: submission.statusTextColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Diajukan pada: ${DateFormat('dd MMM yyyy HH:mm').format(submission.submissionDate)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              if (submission.approvalDate != null &&
                                  submission.approvalDate!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Diperbarui pada: ${submission.approvalDate!}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              if (submission.notes != null &&
                                  submission.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    'Catatan: ${submission.notes!}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              // Tombol untuk melihat dokumen yang diupload
                              if (submission.ktpDocUrl != null &&
                                  submission.ktpDocUrl!.isNotEmpty)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed:
                                        () => _showDocumentDetailModal(
                                          'KTP.pdf',
                                          submission.ktpDocUrl!,
                                        ),
                                    icon: const Icon(Icons.description),
                                    label: const Text('Lihat KTP'),
                                  ),
                                ),
                              if (submission.kkDocUrl != null &&
                                  submission.kkDocUrl!.isNotEmpty)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed:
                                        () => _showDocumentDetailModal(
                                          'KK.pdf',
                                          submission.kkDocUrl!,
                                        ),
                                    icon: const Icon(Icons.description),
                                    label: const Text('Lihat KK'),
                                  ),
                                ),
                              if (submission.businessDocUrl != null &&
                                  submission.businessDocUrl!.isNotEmpty)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed:
                                        () => _showDocumentDetailModal(
                                          'Bukti Usaha.pdf',
                                          submission.businessDocUrl!,
                                        ),
                                    icon: const Icon(Icons.description),
                                    label: const Text('Lihat Bukti Usaha'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
