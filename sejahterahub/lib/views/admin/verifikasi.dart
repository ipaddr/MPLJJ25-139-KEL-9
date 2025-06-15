import 'package:flutter/material.dart';

// Model data dummy untuk pengajuan yang perlu diverifikasi
class PendingSubmission {
  final String id;
  final String name;
  final String nik;
  final String cardType;
  final String status; // Misalnya 'Menunggu'

  // Data detail untuk modal
  final String address;
  final String? ktpDocUrl;
  final String? kkDocUrl;
  final String? businessDocUrl; // Untuk Bukti Usaha

  PendingSubmission({
    required this.id,
    required this.name,
    required this.nik,
    required this.cardType,
    this.status = 'Menunggu',
    required this.address,
    this.ktpDocUrl,
    this.kkDocUrl,
    this.businessDocUrl,
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

  List<PendingSubmission> _allSubmissions = [
    // Data dummy pengajuan
    PendingSubmission(
      id: 'app001',
      name: 'Budi Santoso',
      nik: '3173082504890002',
      cardType: 'Kartu Kesejahteraan',
      address: 'Jl. Merdeka No. 123, Jakarta',
      ktpDocUrl: 'ktp_budi.pdf',
      kkDocUrl: 'kk_budi.pdf',
    ),
    PendingSubmission(
      id: 'app002',
      name: 'Siti Aminah',
      nik: '3173082612910001',
      cardType: 'Kartu Usaha',
      address: 'Jl. Pemuda No. 45, Bandung',
      ktpDocUrl: 'ktp_siti.pdf',
      kkDocUrl: 'kk_siti.pdf',
      businessDocUrl: 'bukti_usaha_siti.pdf',
    ),
    PendingSubmission(
      id: 'app003',
      name: 'Joko Widodo',
      nik: '3173081001700003',
      cardType: 'Kartu Kesejahteraan',
      address: 'Jl. Sudirman No. 78, Surabaya',
      ktpDocUrl: 'ktp_joko.pdf',
      kkDocUrl: 'kk_joko.pdf',
    ),
  ];

  List<PendingSubmission> _filteredSubmissions = [];

  @override
  void initState() {
    super.initState();
    _filteredSubmissions = _allSubmissions;
  }

  void _filterSubmissions(String query) {
    setState(() {
      _filteredSubmissions =
          _allSubmissions.where((submission) {
            final lowerQuery = query.toLowerCase();
            final nameMatches = submission.name.toLowerCase().contains(
              lowerQuery,
            );
            final nikMatches = submission.nik.toLowerCase().contains(
              lowerQuery,
            );
            return nameMatches || nikMatches;
          }).toList();
      _applyCategoryFilter(); // Terapkan filter kategori setelah pencarian
    });
  }

  void _applyCategoryFilter() {
    setState(() {
      if (_selectedCategory == 'Semua') {
        // Jika semua dipilih, filteredSubmissions sudah hasil pencarian
      } else {
        _filteredSubmissions =
            _filteredSubmissions.where((submission) {
              if (_selectedCategory == 'Kesejahteraan') {
                return submission.cardType.contains('Kesejahteraan');
              } else if (_selectedCategory == 'Usaha') {
                return submission.cardType.contains('Usaha');
              }
              return false;
            }).toList();
      }
    });
  }

  void _showDetailModal(PendingSubmission submission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Agar modal bisa scroll kalau kontennya panjang
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
                const SizedBox(height: 16),
                const Text(
                  'Dokumen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (submission.ktpDocUrl != null)
                  _buildDocumentButton('KTP.pdf', submission.ktpDocUrl!),
                if (submission.kkDocUrl != null)
                  _buildDocumentButton('KK.pdf', submission.kkDocUrl!),
                if (submission.businessDocUrl != null)
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Mengajukan ${submission.name} disetujui!',
                              ),
                            ),
                          );
                          Navigator.pop(context); // Tutup modal
                          // TODO: Logika untuk memperbarui status di Firestore
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Warna Setujui
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Setujui'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Mengajukan ${submission.name} ditolak!',
                              ),
                            ),
                          );
                          Navigator.pop(context); // Tutup modal
                          // TODO: Logika untuk memperbarui status di Firestore
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red, // Warna Tolak
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Meminta revisi untuk ${submission.name}!',
                              ),
                            ),
                          );
                          Navigator.pop(context); // Tutup modal
                          // TODO: Logika untuk memperbarui status di Firestore
                          // Mungkin ada form untuk catatan revisi
                        },
                        child: const Text('Minta Revisi'), // Warna default
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Padding bawah untuk keyboard
              ],
            ),
          ),
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
            width: 70, // Lebar tetap untuk label
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mengunduh dokumen: $fileName (simulasi)')),
          );
          // TODO: Implementasi unduh file dari Firebase Storage
        },
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
                    _filterSubmissions(query);
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
                    _buildCategoryChip('Kesejahteraan'),
                    _buildCategoryChip('Usaha'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _filteredSubmissions.length,
              itemBuilder: (context, index) {
                final submission = _filteredSubmissions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: InkWell(
                    onTap:
                        () => _showDetailModal(
                          submission,
                        ), // Tampilkan modal detail
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Menunggu',
                                  style: TextStyle(
                                    color: Colors.orange,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedCategory == label,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = label;
          _filterSubmissions(_searchController.text); // Terapkan filter ulang
        });
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
}
