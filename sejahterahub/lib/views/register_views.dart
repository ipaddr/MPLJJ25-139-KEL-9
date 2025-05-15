import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _kkController = TextEditingController();
  final TextEditingController _ttlController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    if (_namaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.length < 6) {
      _showMessage("Harap isi semua data dengan benar.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Kirim verifikasi email
      await userCredential.user!.sendEmailVerification();

      // Simpan data ke Firestore (opsional)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'nama': _namaController.text,
            'nik': _nikController.text,
            'kk': _kkController.text,
            'ttl': _ttlController.text,
            'no_hp': _hpController.text,
            'email': _emailController.text,
          });

      _showMessage("Pendaftaran berhasil! Silakan verifikasi email Anda.");
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Terjadi kesalahan saat mendaftar.");
    } finally {
      setState(() => _isLoading = false);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  "Selamat Datang",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const Center(
                child: Text(
                  "Daftarkan akun anda",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),

              _buildField(
                "Nama Lengkap",
                "contoh: Udin Laskar",
                _namaController,
              ),
              _buildField(
                "Nomor Induk Kependudukan",
                "contoh: 111199998888",
                _nikController,
              ),
              _buildField(
                "Nomor Kartu Keluarga",
                "contoh: 111199998888",
                _kkController,
              ),
              _buildField(
                "Tempat & Tanggal Lahir",
                "contoh: Makassar, 20/11/11",
                _ttlController,
              ),
              _buildField(
                "No. Handphone",
                "contoh: 08123456789",
                _hpController,
              ),
              _buildField(
                "Alamat Email",
                "contoh@email.co.id",
                _emailController,
              ),
              _buildField(
                "Password",
                "Minimal 6 karakter",
                _passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Daftar",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}
