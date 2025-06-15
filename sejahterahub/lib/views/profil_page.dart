// lib/views/profil_page.dart
import 'package:flutter/material.dart';
import 'package:sejahterahub/views/edit_profil_page.dart'; // Pastikan ini di-import

class ProfilePage extends StatefulWidget {
  // Tambahkan properti untuk data profil
  final String name;
  final String nik;
  final String email;
  final String phone;
  final String address;

  const ProfilePage({
    super.key,
    // Berikan nilai default agar bisa digunakan tanpa argumen (misal dari BottomNavBar)
    this.name = 'Sumanto',
    this.nik = '3275021504900002',
    this.email = 'sumanto@gmail.com',
    this.phone = '+62 812-8456-7890',
    this.address =
        'Jl. Mawar No. 123, RT 005/RW 002, Kel. Sukamaju, Kec. Cilodong, Kota Depok',
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Gunakan variabel state untuk menyimpan data profil yang bisa di-update
  late String _currentName;
  late String _currentNik;
  late String _currentEmail;
  late String _currentPhone;
  late String _currentAddress;

  @override
  void initState() {
    super.initState();
    _currentName = widget.name;
    _currentNik = widget.nik;
    _currentEmail = widget.email;
    _currentPhone = widget.phone;
    _currentAddress = widget.address;
  }

  // Fungsi untuk mengupdate state setelah kembali dari EditProfilePage
  void _updateProfileData({
    String? name,
    String? nik,
    String? email,
    String? phone,
    String? address,
  }) {
    setState(() {
      if (name != null) _currentName = name;
      if (nik != null) _currentNik = nik;
      if (email != null) _currentEmail = email;
      if (phone != null) _currentPhone = phone;
      if (address != null) _currentAddress = address;
    });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                'https://placekitten.com/200/200', // Ganti dengan foto profil
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentName, // Gunakan state
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('NIK: $_currentNik'), // Gunakan state
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                // Saat navigasi ke EditProfilePage, kirim data saat ini
                final updatedData = await Navigator.push(
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

                // Jika ada data yang kembali dari EditProfilePage, update state
                if (updatedData != null && updatedData is Map<String, String>) {
                  _updateProfileData(
                    name: updatedData['name'],
                    nik: updatedData['nik'],
                    email: updatedData['email'],
                    phone: updatedData['phone'],
                    address: updatedData['address'],
                  );
                }
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
                Text(_currentEmail), // Gunakan state
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_outlined),
                const SizedBox(width: 8),
                Text(_currentPhone), // Gunakan state
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentAddress, // Gunakan state
                  ),
                ),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Fitur logout belum diimplementasi (tanpa Firebase).',
                    ),
                  ),
                );
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
