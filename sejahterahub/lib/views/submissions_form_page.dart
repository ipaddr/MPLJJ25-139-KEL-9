// lib/views/submission_form_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sejahterahub/services/cloudinary_service.dart';

class SubmissionFormPage extends StatefulWidget {
  const SubmissionFormPage({super.key});

  @override
  State<SubmissionFormPage> createState() => _SubmissionFormPageState();
}

class _SubmissionFormPageState extends State<SubmissionFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCardType;
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _kkController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  PlatformFile? _ktpFile;
  PlatformFile? _kkFile;
  PlatformFile? _businessFile;

  bool _isSubmitting = false;

  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void dispose() {
    _nikController.dispose();
    _kkController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String fileType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        if (fileType == 'ktp') {
          _ktpFile = result.files.first;
        } else if (fileType == 'kk') {
          _kkFile = result.files.first;
        } else if (fileType == 'business') {
          _businessFile = result.files.first;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File ${result.files.first.name} dipilih.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pemilihan file dibatalkan.')),
      );
    }
  }

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSubmitting = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anda harus login untuk mengajukan bantuan.'),
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        final String userId =
            user.uid; // <-- Pastikan userId dideklarasikan di sini
        final String timestamp =
            DateTime.now().millisecondsSinceEpoch
                .toString(); // <-- PASTIKAN INI DI SINI

        if (_ktpFile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Harap unggah file KTP.')),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
        if (_kkFile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Harap unggah file Kartu Keluarga.')),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
        if (_selectedCardType == 'Kartu Usaha' && _businessFile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Harap unggah Bukti Usaha untuk pengajuan Kartu Usaha.',
              ),
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        String? ktpUrl = await _cloudinaryService.uploadFile(
          platformFile: _ktpFile!,
          fileType: _ktpFile!.extension == 'pdf' ? 'raw' : 'image',
        );
        String? kkUrl = await _cloudinaryService.uploadFile(
          platformFile: _kkFile!,
          fileType: _kkFile!.extension == 'pdf' ? 'raw' : 'image',
        );
        String? businessUrl;
        if (_selectedCardType == 'Kartu Usaha' && _businessFile != null) {
          businessUrl = await _cloudinaryService.uploadFile(
            platformFile: _businessFile!,
            fileType: _businessFile!.extension == 'pdf' ? 'raw' : 'image',
          );
        }

        if (ktpUrl == null ||
            kkUrl == null ||
            (_selectedCardType == 'Kartu Usaha' && businessUrl == null)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proses unggah dokumen gagal. Harap coba lagi.'),
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        await FirebaseFirestore.instance.collection('submissions').add({
          'userId': userId,
          'cardType': _selectedCardType,
          'nik': _nikController.text.trim(),
          'kk': _kkController.text.trim(),
          'address': _addressController.text.trim(),
          'ktpDocUrl': ktpUrl,
          'kkDocUrl': kkUrl,
          'businessDocUrl': businessUrl,
          'submissionDate': FieldValue.serverTimestamp(),
          'status': 'Menunggu Verifikasi',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengajuan $_selectedCardType berhasil dikirim!'),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error submitting application: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat mengirim pengajuan: $e'),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Pengajuan Bantuan'),
        centerTitle: true,
      ),
      body:
          _isSubmitting
              ? const Center(child: CircularProgressIndicator(strokeWidth: 4.0))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Jenis Bantuan/Kartu:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Jenis Bantuan/Kartu',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        value: _selectedCardType,
                        hint: const Text('Pilih salah satu'),
                        items:
                            <String>[
                              'Kartu Kesejahteraan',
                              'Kartu Usaha',
                              'Bantuan Pendidikan',
                              'Bantuan Pangan',
                              'Program Prakerja',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCardType = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap pilih jenis bantuan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Data Pribadi Pengaju:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nikController,
                        decoration: const InputDecoration(
                          labelText: 'NIK (Nomor Induk Kependudukan)',
                          hintText: 'Contoh: 1234567890123456',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 16) {
                            return 'NIK harus 16 digit angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _kkController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Kartu Keluarga (KK)',
                          hintText: 'Contoh: 1234567890123456',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 16) {
                            return 'Nomor KK harus 16 digit angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Lengkap',
                          hintText: 'Contoh: Jl. Mawar No. 123',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap masukkan alamat lengkap';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Unggah Dokumen Pendukung:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFileUploadButton(
                        label: 'Unggah KTP (.pdf/.jpg)',
                        fileName: _ktpFile?.name,
                        onPressed: () => _pickFile('ktp'),
                      ),
                      const SizedBox(height: 12),
                      _buildFileUploadButton(
                        label: 'Unggah Kartu Keluarga (.pdf/.jpg)',
                        fileName: _kkFile?.name,
                        onPressed: () => _pickFile('kk'),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedCardType == 'Kartu Usaha')
                        _buildFileUploadButton(
                          label: 'Unggah Bukti Usaha (.pdf/.jpg)',
                          fileName: _businessFile?.name,
                          onPressed: () => _pickFile('business'),
                        ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitApplication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Kirim Pengajuan',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildFileUploadButton({
    required String label,
    String? fileName,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.upload_file),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(40),
          ),
        ),
        if (fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8.0),
            child: Text(
              'File terpilih: $fileName',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
