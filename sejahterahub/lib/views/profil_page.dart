import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
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
            const Text(
              'Sumanto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('NIK: 3275021504900002'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Edit Profil'),
            ),
            const Divider(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Data Diri', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.email_outlined),
                SizedBox(width: 8),
                Text('sumanto@gmail.com'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.phone_outlined),
                SizedBox(width: 8),
                Text('+62 812-8456-7890'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.location_on_outlined),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jl. Mawar No. 123, RT 005/RW 002, Kel. Sukamaju, Kec. Cilodong, Kota Depok',
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Riwayat Pendaftaran', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: const Text('Kartu Kesejahteraan'),
                subtitle: const Text('Diajukan: 15 Mar 2025'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: const Text('Bantuan UMKM'),
                subtitle: const Text('Diajukan: 02 Feb 2025'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              onPressed: () {},
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
