// lib/services/cloudinary_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class CloudinaryService {
  // GANTI DENGAN CLOUD NAME ANDA DARI DASHBOARD CLOUDINARY
  static const String CLOUD_NAME = 'ddrnvxshy';
  // OPTIONAL: Jika Anda ingin menggunakan unsigned upload preset
  static const String UPLOAD_PRESET =
      'my_unsigned_preset'; // Contoh: 'ml_default'

  // Fungsi untuk mengunggah gambar/file ke Cloudinary
  // `fileType` bisa 'image' atau 'raw' (untuk dokumen)
  Future<String?> uploadFile({
    required PlatformFile platformFile,
    String fileType = 'image',
  }) async {
    if (platformFile.path == null) {
      print("Error: File path is null.");
      return null;
    }

    // URL upload: ganti 'image' dengan 'raw' jika dokumen (pdf, dll)
    final String uploadUrl =
        'https://api.cloudinary.com/v1_1/$CLOUD_NAME/$fileType/upload';

    try {
      final file = File(
        platformFile.path!,
      ); // Convert PlatformFile to dart:io File
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Tambahkan file ke request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Nama field ini harus 'file'
          file.path,
          filename: platformFile.name,
        ),
      );

      // Tambahkan unsigned upload preset jika Anda menggunakannya
      if (UPLOAD_PRESET.isNotEmpty) {
        request.fields['upload_preset'] = UPLOAD_PRESET;
      }

      // Kirim request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseBody);
        final String? secureUrl =
            data['secure_url']; // Ambil secure_url atau url
        return secureUrl;
      } else {
        print(
          'Cloudinary upload failed with status ${response.statusCode}: $responseBody',
        );
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }
}
