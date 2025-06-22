// lib/views/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:sejahterahub/views/admin/admin_notifications_page.dart';
// Import for date formatting

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Untuk menghitung total pengguna (jika ada koleksi 'users')
  Stream<int> _getTotalUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // Untuk menghitung pengajuan hari ini
  Stream<int> _getTodaySubmissionsCount() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return FirebaseFirestore.instance
        .collection('submissions')
        .where('submissionDate', isGreaterThanOrEqualTo: startOfDay)
        .where(
          'submissionDate',
          isLessThanOrEqualTo: endOfDay,
        ) // Use isLessThanOrEqualTo for end of day
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // Untuk menghitung pengajuan yang menunggu verifikasi hari ini
  Stream<int> _getPendingSubmissionsTodayCount() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return FirebaseFirestore.instance
        .collection('submissions')
        .where('status', isEqualTo: 'Menunggu Verifikasi')
        .where('submissionDate', isGreaterThanOrEqualTo: startOfDay)
        .where('submissionDate', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // Untuk menghitung kartu yang disetujui (total)
  Stream<int> _getApprovedCardsCount() {
    return FirebaseFirestore.instance
        .collection('submissions')
        .where('status', isEqualTo: 'Disetujui')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // Untuk menghitung pengaduan aktif (asumsi ada koleksi 'complaints' dengan status 'active')
  Stream<int> _getActiveComplaintsCount() {
    // Anda perlu memiliki koleksi 'complaints' di Firestore untuk ini
    // Dan field 'status' di dalamnya (misalnya 'active', 'resolved')
    return FirebaseFirestore.instance
        .collection('complaints') // <--- Ganti dengan nama koleksi pengaduanmu
        .where(
          'status',
          isEqualTo: 'active',
        ) // <--- Ganti dengan status yang sesuai
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

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
    bool isLoading = false, // Tambah parameter isLoading
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
                  isLoading
                      ? const CircularProgressIndicator() // Tampilkan loading
                      : Text(
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
          // Ikon notifikasi yang sekarang navigasi ke halaman notifikasi
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminNotificationsPage(),
                ),
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
                Navigator.pop(context); // Tutup drawer
                Navigator.pushNamed(
                  context,
                  '/admin/manage_articles',
                ); // <-- Navigasi ke halaman kelola artikel
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
            // Statistik Total Pengguna
            StreamBuilder<int>(
              stream: _getTotalUsers(),
              builder: (context, snapshot) {
                return _buildStatCard(
                  title: 'Total Pengguna',
                  value: snapshot.hasData ? '${snapshot.data}' : '...',
                  subtitle: 'Data dari koleksi users',
                  icon: Icons.people,
                  iconColor: Colors.blue,
                  isLoading: !snapshot.hasData,
                );
              },
            ),
            // Statistik Pengajuan Hari Ini
            StreamBuilder<int>(
              stream: _getTodaySubmissionsCount(),
              builder: (context, snapshotToday) {
                return StreamBuilder<int>(
                  stream: _getPendingSubmissionsTodayCount(),
                  builder: (context, snapshotPending) {
                    return _buildStatCard(
                      title: 'Pengajuan Hari Ini',
                      value:
                          snapshotToday.hasData
                              ? '${snapshotToday.data}'
                              : '...',
                      subtitle:
                          snapshotPending.hasData
                              ? '${snapshotPending.data} menunggu verifikasi'
                              : '...',
                      icon: Icons.description,
                      iconColor: Colors.orange,
                      isLoading:
                          !snapshotToday.hasData || !snapshotPending.hasData,
                    );
                  },
                );
              },
            ),
            // Statistik Kartu Disetujui
            StreamBuilder<int>(
              stream: _getApprovedCardsCount(),
              builder: (context, snapshot) {
                return _buildStatCard(
                  title: 'Kartu Disetujui',
                  value: snapshot.hasData ? '${snapshot.data}' : '...',
                  subtitle:
                      'Total sepanjang waktu', // Sesuaikan subtitle jika ingin filter bulan/tahun
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  isLoading: !snapshot.hasData,
                );
              },
            ),
            // Statistik Pengaduan Aktif
            StreamBuilder<int>(
              stream: _getActiveComplaintsCount(),
              builder: (context, snapshot) {
                return _buildStatCard(
                  title: 'Pengaduan Aktif',
                  value: snapshot.hasData ? '${snapshot.data}' : '...',
                  subtitle: 'Perlu tindakan segera',
                  icon: Icons.warning,
                  iconColor: Colors.red,
                  isLoading: !snapshot.hasData,
                );
              },
            ),
            const SizedBox(height: 16),
            // Bagian notifikasi sistem yang dipindahkan ke halaman terpisah
            // Jadi, bagian ini tidak perlu ada lagi di sini
            // const Text(
            //   'Notifikasi Sistem Terbaru',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 10),
            // _buildNotificationCard(...),
          ],
        ),
      ),
    );
  }
}
