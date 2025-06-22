// lib/views/admin/admin_notifications_page.dart
import 'package:flutter/material.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  // Widget untuk notifikasi sistem (sama seperti yang sebelumnya)
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
      appBar: AppBar(title: const Text('Notifikasi Sistem'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            // Tambahkan notifikasi lain di sini jika ada
          ],
        ),
      ),
    );
  }
}
