// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // <-- Pastikan import ini ada
import 'package:sejahterahub/routes/routes.dart';

void main() async {
  // <-- Pastikan ada 'async' di sini
  // Memastikan bahwa Flutter binding sudah diinisialisasi
  // Ini penting sebelum memanggil metode plugin (seperti Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // Menginisialisasi Firebase untuk aplikasi Anda
  // Ini harus dipanggil sebelum menggunakan layanan Firebase apa pun
  await Firebase.initializeApp();

  // Menjalankan aplikasi Flutter
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SejahteraHub',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Mengatur rute awal ke splashscreen
      routes: appRoutes, // Menggunakan rute dari routes.dart
    );
  }
}
