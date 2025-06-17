// lib/views/profil_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import untuk Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import untuk Firestore
import 'package:sejahterahub/views/edit_profil_page.dart'; // Pastikan ini di-import

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variabel state untuk menyimpan data profil
  String _currentName = 'Memuat...';
  String _currentNik = 'Memuat...';
  String _currentEmail = 'Memuat...';
  String _currentPhone = 'Memuat...';
  String _currentAddress = 'Memuat...';

  // Indikator loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Panggil fungsi untuk memuat data saat halaman dibuat
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true; // Set loading true saat memulai pemuatan
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ambil data pengguna dari Firestore
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _currentName = userData['nama'] ?? 'Nama Tidak Tersedia';
            _currentNik = userData['nik'] ?? 'NIK Tidak Tersedia';
            _currentEmail = userData['email'] ?? 'Email Tidak Tersedia';
            _currentPhone = userData['no_hp'] ?? 'No. HP Tidak Tersedia';
            _currentAddress =
                userData['address'] ??
                'Alamat Tidak Tersedia'; // Pastikan ada field 'address' di Firestore
          });
        } else {
          // Jika dokumen user tidak ditemukan di Firestore
          setState(() {
            _currentName = 'Data Tidak Ditemukan';
            _currentEmail =
                user.email ??
                'Email Tidak Tersedia'; // Set email dari Auth jika data Firestore tidak ada
          });
        }
      } else {
        // Jika tidak ada user yang login
        setState(() {
          _currentName = 'Belum Login';
          _currentEmail = 'Tidak Ada Akun';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat profil: $e')));
      setState(() {
        _currentName = 'Error Memuat';
      });
    } finally {
      setState(() {
        _isLoading = false; // Set loading false setelah pemuatan selesai
      });
    }
  }

  // Fungsi untuk mengupdate state setelah kembali dari EditProfilePage
  // Sekarang juga akan memicu pemuatan ulang dari Firestore
  void _updateProfileData() {
    _loadUserProfile(); // Panggil ulang untuk memuat data terbaru setelah edit
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: const Text('Profil Saya'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Tampilkan loading
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        'https://placekitten.com/200/200', // Ganti dengan foto profil user
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('NIK: $_currentNik'),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () async {
                        // Kirim data saat ini ke halaman edit profil
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditProfilePage(
                                  initialName: _currentName,
                                  initialNik: _currentNik,
                                  initialEmail: _currentEmail,
                                  initialPhone: _currentPhone,
                                  initialAddress: _currentAddress,
                                ),
                          ),
                        );
                        // Setelah kembali dari EditProfilePage, muat ulang profil
                        _updateProfileData();
                      },
                      child: const Text('Edit Profil'),
                    ),
                    const Divider(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Data Diri',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined),
                        const SizedBox(width: 8),
                        Text(_currentEmail),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined),
                        const SizedBox(width: 8),
                        Text(_currentPhone),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_currentAddress)),
                      ],
                    ),
                    const Divider(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Riwayat Pendaftaran',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Riwayat pendaftaran ini nantinya juga diambil dari Firestore
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: const Text('Kartu Kesejahteraan'),
                        subtitle: const Text('Diajukan: 15 Mar 2025'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Sedang Diproses',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: const Text('Bantuan UMKM'),
                        subtitle: const Text('Diajukan: 02 Feb 2025'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Disetujui',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () async {
                        // Logout dari Firebase Auth
                        await FirebaseAuth.instance.signOut();
                        // Kembali ke halaman login
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
