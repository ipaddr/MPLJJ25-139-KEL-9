// lib/views/tracking_status_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:sejahterahub/models/submission.dart'; // Import model Submission

class TrackingStatusPage extends StatefulWidget {
  const TrackingStatusPage({super.key});

  @override
  State<TrackingStatusPage> createState() => _TrackingStatusPageState();
}

class _TrackingStatusPageState extends State<TrackingStatusPage> {
  // Daftar pengajuan dummy
  List<Submission> _submissions = [
    Submission(
      id: 'sub001',
      cardType: 'Kartu Kesejahteraan',
      submissionDate: DateTime(2025, 3, 15),
      status: 'Sedang Diproses',
      notes: 'Verifikasi dokumen sedang berlangsung.',
    ),
    Submission(
      id: 'sub002',
      cardType: 'Bantuan UMKM',
      submissionDate: DateTime(2025, 2, 2),
      status: 'Disetujui',
      approvalDate: '10 Feb 2025',
      notes: 'Dana akan dicairkan dalam 3 hari kerja.',
    ),
    Submission(
      id: 'sub003',
      cardType: 'Kartu Prakerja',
      submissionDate: DateTime(2025, 1, 20),
      status: 'Ditolak',
      approvalDate: '25 Jan 2025',
      notes:
          'Persyaratan usia tidak terpenuhi. Silakan cek kriteria di halaman edukasi.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lacak Status Pengajuan')),
      body:
          _submissions.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text(
                        'Anda belum memiliki pengajuan yang sedang diproses.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Silakan ajukan permohonan kartu untuk melihat status di sini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          // Arahkan ke halaman pendaftaran kartu
                          Navigator.pushNamed(
                            context,
                            '/register',
                          ); // Atau ke halaman khusus daftar kartu jika dibuat
                        },
                        child: const Text('Ajukan Permohonan Sekarang'),
                      ),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _submissions.length,
                itemBuilder: (context, index) {
                  final submission = _submissions[index];
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  color: submission.statusColor.withOpacity(
                                    0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      submission.statusIcon,
                                      size: 16,
                                      color: submission.statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      submission.status,
                                      style: TextStyle(
                                        color: submission.statusColor,
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
                            'Diajukan pada: ${DateFormat('dd MMM yyyy').format(submission.submissionDate)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          if (submission.approvalDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Diperbarui pada: ${submission.approvalDate}',
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
                          // Anda bisa menambahkan tombol "Lihat Detail" di sini
                          // ElevatedButton(
                          //   onPressed: () {
                          //     // Navigasi ke halaman detail pengajuan
                          //   },
                          //   child: const Text('Lihat Detail'),
                          // ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
