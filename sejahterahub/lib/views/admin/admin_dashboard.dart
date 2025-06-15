// lib/views/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Widget untuk kartu statistik
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    Color iconColor = Colors.black,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 40, color: iconColor),
          ],
        ),
      ),
    );
  }

  // Widget untuk notifikasi sistem
  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required String timeAgo,
    required IconData icon,
    Color iconColor = Colors.black,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifikasi admin.')),
              );
            },
          ),
          // Ikon profil admin yang juga berfungsi sebagai tombol logout
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Admin SejahteraHub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard Utama'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Verifikasi Pengguna & Pengajuan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/verification');
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Kelola Artikel & Berita'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigasi ke halaman kelola artikel.'),
                  ),
                );
                // TODO: Navigasi ke halaman kelola artikel (akan kita buat nanti)
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(
              title: 'Total Pengguna',
              value: '24,512',
              subtitle: '+12% dari bulan lalu',
              icon: Icons.people,
              iconColor: Colors.blue,
            ),
            _buildStatCard(
              title: 'Pengajuan Hari Ini',
              value: '156',
              subtitle: '32 menunggu verifikasi',
              icon: Icons.description,
              iconColor: Colors.orange,
            ),
            _buildStatCard(
              title: 'Kartu Disetujui',
              value: '1,248',
              subtitle: 'Bulan April 2025',
              icon: Icons.check_circle,
              iconColor: Colors.green,
            ),
            _buildStatCard(
              title: 'Pengaduan Aktif',
              value: '24',
              subtitle: '8 perlu tindakan segera',
              icon: Icons.warning,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Notifikasi Sistem Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildNotificationCard(
              title: 'Pembaruan Sistem',
              subtitle:
                  'Pembaruan sistem akan dilakukan pada 25 April 2025 pukul 02:00 WIB',
              timeAgo: '2 jam yang lalu',
              icon: Icons.info,
              iconColor: Colors.blueAccent,
            ),
            _buildNotificationCard(
              title: 'Peringatan Keamanan',
              subtitle:
                  'Terdeteksi 3 percobaan login tidak valid dari IP 192.168.1.1',
              timeAgo: '5 jam yang lalu',
              icon: Icons.security,
              iconColor: Colors.orangeAccent,
            ),
            _buildNotificationCard(
              title: 'Laporan Mingguan',
              subtitle: 'Laporan mingguan telah tersedia untuk diunduh',
              timeAgo: '1 hari yang lalu',
              icon: Icons.assignment,
              iconColor: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }
}
