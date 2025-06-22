// lib/views/admin/verification_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Model data untuk pengajuan (tetap sama)
class PendingSubmission {
  final String id;
  final String name;
  final String nik;
  final String cardType;
  final String status;
  final String address;
  final String? ktpDocUrl;
  final String? kkDocUrl;
  final String? businessDocUrl;
  final DateTime submissionDate;
  final String userId;

  PendingSubmission({
    required this.id,
    required this.name,
    required this.nik,
    required this.cardType,
    required this.status,
    required this.address,
    this.ktpDocUrl,
    this.kkDocUrl,
    this.businessDocUrl,
    required this.submissionDate,
    required this.userId,
  });
}

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  // --- START: FIREBASE DATA FETCHING & MANIPULATION ---

  Stream<List<PendingSubmission>> _getSubmissionsStream() {
    return FirebaseFirestore.instance
        .collection('submissions')
        .orderBy('submissionDate', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<PendingSubmission> submissions = [];
          for (var doc in snapshot.docs) {
            final data = doc.data(); // Pastikan data ada di sini

            String userName = 'User Tidak Ditemukan';
            String userAddress = data['address'] ?? 'Alamat Tidak Tersedia';
            String currentUserId =
                data['userId'] ??
                ''; // Ambil userId dari data, default string kosong jika null

            // PERBAIKAN DI SINI: Lakukan pengecekan userId sebelum mencoba fetch userDoc
            if (currentUserId.isNotEmpty) {
              // Hanya fetch jika userId tidak kosong
              final userDoc =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserId)
                      .get();
              if (userDoc.exists && userDoc.data() != null) {
                userName = userDoc.data()!['nama'] ?? 'Nama Tidak Tersedia';
              } else {
                // Fallback: Jika dokumen user tidak ditemukan, ambil nama dari submission jika ada
                userName =
                    data['name'] ??
                    'User Tidak Ditemukan'; // Asumsi 'name' mungkin ada langsung di submission
              }
            } else {
              // Jika userId kosong, gunakan nama dari data submission jika ada
              userName = data['name'] ?? 'User Tidak Ditemukan (UID kosong)';
            }

            submissions.add(
              PendingSubmission(
                id: doc.id,
                name: userName,
                nik: data['nik'] ?? 'N/A',
                cardType: data['cardType'] ?? 'N/A',
                status: data['status'] ?? 'Menunggu Verifikasi',
                address: userAddress,
                ktpDocUrl: data['ktpDocUrl'],
                kkDocUrl: data['kkDocUrl'],
                businessDocUrl: data['businessDocUrl'],
                submissionDate: (data['submissionDate'] as Timestamp).toDate(),
                userId:
                    currentUserId, // Gunakan userId yang sudah di-null-check
              ),
            );
          }
          return submissions;
        });
  }

  Future<void> _updateSubmissionStatus(
    String submissionId,
    String status, {
    String? notes,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(submissionId)
          .update({
            'status': status,
            'notes': notes,
            'approvalDate': FieldValue.serverTimestamp(),
            'adminId': FirebaseAuth.instance.currentUser?.uid,
          });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengajuan berhasil diupdate menjadi: $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengupdate status: $e')));
    }
  }

  // --- END: FIREBASE DATA FETCHING & MANIPULATION ---

  // --- START: HELPER METHODS FOR UI ---

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tidak dapat membuka link: $url')));
    }
  }

  Future<String?> _showNotesDialog(BuildContext context, String title) async {
    final TextEditingController notesController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(
              hintText:
                  'Masukkan catatan (misal: Alasan penolakan, dokumen yang perlu direvisi)',
            ),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, notesController.text),
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDocumentButton(String fileName, String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: OutlinedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: const Icon(Icons.file_copy),
        label: Text(fileName),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  void _showDetailModal(PendingSubmission submission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detail Aplikasi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const Text(
                  'Data Pribadi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Nama', submission.name),
                _buildDetailRow('NIK', submission.nik),
                _buildDetailRow('Alamat', submission.address),
                _buildDetailRow('Jenis Kartu', submission.cardType),
                _buildDetailRow(
                  'Tgl Pengajuan',
                  DateFormat('dd MMM, HH:mm').format(submission.submissionDate),
                ),
                _buildDetailRow('Status Saat Ini', submission.status),
                const SizedBox(height: 16),
                const Text(
                  'Dokumen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (submission.ktpDocUrl != null &&
                    submission.ktpDocUrl!.isNotEmpty)
                  _buildDocumentButton('KTP.pdf', submission.ktpDocUrl!),
                if (submission.kkDocUrl != null &&
                    submission.kkDocUrl!.isNotEmpty)
                  _buildDocumentButton('KK.pdf', submission.kkDocUrl!),
                if (submission.businessDocUrl != null &&
                    submission.businessDocUrl!.isNotEmpty)
                  _buildDocumentButton(
                    'Bukti_Usaha.pdf',
                    submission.businessDocUrl!,
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _updateSubmissionStatus(
                            submission.id,
                            'Disetujui',
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Setujui'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final String? notes = await _showNotesDialog(
                            context,
                            'Tolak Pengajuan',
                          );
                          if (notes != null) {
                            await _updateSubmissionStatus(
                              submission.id,
                              'Ditolak',
                              notes: notes,
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final String? notes = await _showNotesDialog(
                            context,
                            'Minta Revisi',
                          );
                          if (notes != null) {
                            await _updateSubmissionStatus(
                              submission.id,
                              'Minta Revisi',
                              notes: notes,
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Minta Revisi'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper untuk mendapatkan warna background status
  Color _getStatusColor(String status) {
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

  // Helper untuk mendapatkan warna teks status
  Color _getStatusTextColor(String status) {
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

  // Widget _buildCategoryChip (INI METODE YANG ERROR SEBELUMNYA, DIPASTIKAN ADA DI SINI)
  Widget _buildCategoryChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedCategory == label,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = label;
        }); // Memicu rebuild StreamBuilder untuk filter
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color:
            _selectedCategory == label
                ? Theme.of(context).primaryColor
                : Colors.black,
      ),
    );
  }
  // --- END: HELPER METHODS FOR UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Pengajuan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau NIK...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryChip('Semua'),
                    _buildCategoryChip('Menunggu Verifikasi'),
                    _buildCategoryChip('Disetujui'),
                    _buildCategoryChip('Ditolak'),
                    _buildCategoryChip('Minta Revisi'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PendingSubmission>>(
              stream: _getSubmissionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada pengajuan ditemukan.'),
                  );
                }

                List<PendingSubmission> allSubmissions = snapshot.data!;
                List<PendingSubmission> filteredSubmissions =
                    allSubmissions.where((submission) {
                      final lowerQuery = _searchController.text.toLowerCase();
                      final nameMatches = submission.name
                          .toLowerCase()
                          .contains(lowerQuery);
                      final nikMatches = submission.nik.toLowerCase().contains(
                        lowerQuery,
                      );

                      bool categoryFilterMatches = true;
                      if (_selectedCategory != 'Semua') {
                        categoryFilterMatches =
                            submission.status.toLowerCase() ==
                            _selectedCategory.toLowerCase();
                      }

                      return (nameMatches || nikMatches) &&
                          categoryFilterMatches;
                    }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredSubmissions.length,
                  itemBuilder: (context, index) {
                    final submission = filteredSubmissions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _showDetailModal(submission),
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
                                    submission.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(submission.status),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      submission.status,
                                      style: TextStyle(
                                        color: _getStatusTextColor(
                                          submission.status,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NIK: ${submission.nik}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text('Kartu ${submission.cardType}'),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _showDetailModal(submission),
                                  child: const Text('Lihat Detail'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
