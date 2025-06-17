// lib/views/edit_profil_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialNik;
  final String initialEmail;
  final String initialPhone;
  final String initialAddress;

  const EditProfilePage({
    super.key,
    this.initialName = 'Sumanto',
    this.initialNik = '3275021504900002',
    this.initialEmail = 'sumanto@gmail.com',
    this.initialPhone = '+62 812-8456-7890',
    this.initialAddress =
        'Jl. Mawar No. 123, RT 005/RW 002, Kel. Sukamaju, Kec. Cilodong, Kota Depok',
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _nikController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _nikController = TextEditingController(text: widget.initialNik);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true; // Set saving true saat proses dimulai
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'nama': _nameController.text.trim(),
              'nik': _nikController.text.trim(),
              'email': _emailController.text.trim(),
              'no_hp': _phoneController.text.trim(),
              'address': _addressController.text.trim(),
              // Jangan lupa field 'ttl' dan 'kk' jika ada
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan profil berhasil disimpan!')),
        );
        Navigator.pop(context); // Kembali ke halaman profil
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada pengguna yang login.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan perubahan: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false; // Set saving false setelah proses selesai
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://placekitten.com/200/200', // Ganti dengan foto profil
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      color: Colors.blue,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Fitur ubah foto profil belum diimplementasi.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nikController,
              decoration: const InputDecoration(
                labelText: 'NIK',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Nomor Handphone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child:
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
