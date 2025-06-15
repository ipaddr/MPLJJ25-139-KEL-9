// lib/views/auth/login_views.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage("Harap isi email dan password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Login gagal, pengguna tidak ditemukan.");
      }

      // 1. Cek apakah UID pengguna ada di koleksi 'admins'
      final adminDoc =
          await FirebaseFirestore.instance
              .collection('admins')
              .doc(
                user.uid,
              ) // Mencari dokumen dengan UID yang sama dengan user login
              .get();

      if (adminDoc.exists) {
        // Jika ada di koleksi 'admins', maka dia adalah admin
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        // Jika tidak ada di koleksi 'admins', cek apakah ada di koleksi 'users'
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists && userDoc.data()!['role'] == 'user') {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Jika tidak ditemukan di 'admins' maupun sebagai 'user'
          // Ini bisa jadi akun baru yang belum lengkap datanya, atau anomali.
          // Untuk amannya, logout dan suruh daftar/cek data.
          await FirebaseAuth.instance.signOut(); // Logout
          _showMessage(
            "Data peran pengguna tidak ditemukan. Silakan daftar ulang atau hubungi admin.",
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Terjadi kesalahan.");
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 16),
                const Text(
                  "Selamat Datang,",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Log in untuk melanjutkan",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: Icon(Icons.visibility),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showMessage('Fitur lupa password tidak tersedia');
                    },
                    child: const Text("Lupa Password Anda?"),
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                        backgroundColor: const Color.fromARGB(
                          255,
                          33,
                          150,
                          243,
                        ),
                      ),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("atau belum punya akun? Daftar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
