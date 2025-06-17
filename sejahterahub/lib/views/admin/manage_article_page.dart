// lib/views/admin/manage_articles_page.dart
import 'package:flutter/material.dart';
import 'package:sejahterahub/models/edukasi_content.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io'; // Untuk FileImage
import 'package:sejahterahub/services/cloudinary_service.dart';

class ManageArticlesPage extends StatefulWidget {
  const ManageArticlesPage({super.key});

  @override
  State<ManageArticlesPage> createState() => _ManageArticlesPageState();
}

class _ManageArticlesPageState extends State<ManageArticlesPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryFilter;

  final Uuid uuid = Uuid();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // File sementara untuk gambar yang dipilih di modal
  PlatformFile? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // Pemicu rebuild saat teks pencarian berubah, agar StreamBuilder re-evaluate filter
      setState(() {});
    });
  }

  // Fungsi untuk mendapatkan stream artikel dari Firestore
  Stream<List<EdukasiContent>> _getArticlesStream() {
    return FirebaseFirestore.instance
        .collection('articles')
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) {
              return EdukasiContent(
                id: doc.id,
                type: 'Error',
                title: 'Data Error',
                duration: 'N/A',
                views: 'N/A',
                imageUrl: '',
                fullContent: 'Data artikel kosong atau rusak.',
                tags: const [],
              );
            }
            return EdukasiContent(
              id: doc.id,
              type: data['type'] ?? 'Artikel',
              title: data['title'] ?? 'Tanpa Judul',
              duration: data['duration'] ?? 'N/A',
              views: data['views'] ?? '0 views',
              imageUrl: data['imageUrl'] ?? '',
              fullContent: data['fullContent'] ?? '',
              tags: List<String>.from(data['tags'] ?? []),
            );
          }).toList();
        });
  }

  // Fungsi untuk menambah atau mengedit artikel di Firestore
  Future<void> _saveArticleToFirestore({
    EdukasiContent? article,
    required String title,
    required String content,
    String? imageUrl,
    String? category,
  }) async {
    final CollectionReference articlesCollection = FirebaseFirestore.instance
        .collection('articles');
    final user = FirebaseAuth.instance.currentUser;

    Map<String, dynamic> dataToSave = {
      'type': 'Artikel',
      'title': title,
      'fullContent': content,
      'imageUrl': imageUrl ?? '',
      'tags': category != null ? ['#$category'] : [],
      'duration': article?.duration ?? 'Baru',
      'views': article?.views ?? '0 views',
      'lastUpdated': FieldValue.serverTimestamp(),
      'authorId': user?.uid,
    };

    if (article == null) {
      dataToSave['createdAt'] = FieldValue.serverTimestamp();
      await articlesCollection.add(dataToSave);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Artikel "$title" berhasil ditambahkan!')),
      );
    } else {
      await articlesCollection.doc(article.id).update(dataToSave);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Artikel "$title" berhasil diperbarui!')),
      );
    }
  }

  // Fungsi untuk menghapus artikel dari Firestore
  Future<void> _deleteArticleFromFirestore(
    String articleId,
    String title,
  ) async {
    final bool confirmDelete =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi Hapus'),
              content: Text(
                'Anda yakin ingin menghapus artikel "$title" secara permanen?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Hapus'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmDelete) {
      try {
        await FirebaseFirestore.instance
            .collection('articles')
            .doc(articleId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artikel "$title" berhasil dihapus!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus artikel: $e')));
      }
    }
  }

  void _showArticleForm({EdukasiContent? article}) {
    final TextEditingController titleController = TextEditingController(
      text: article?.title,
    );
    final TextEditingController contentController = TextEditingController(
      text: article?.fullContent,
    );
    String? currentCategory =
        (article?.tags != null && article!.tags.isNotEmpty)
            ? article.tags.first.substring(1)
            : null;
    String? currentImageUrl = article?.imageUrl;

    // Pastikan _selectedImageFile diinisialisasi ulang di sini agar bersih setiap buka modal
    // atau jika Anda ingin mempertahankan pilihan saat modal tertutup dan dibuka lagi,
    // maka ini harus jadi state di _ManageArticlesPageState, bukan di dalam modalSetState.
    // Untuk tujuan ini, kita akan reset di sini.
    _selectedImageFile = null; // <-- Reset di sini

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          article == null
                              ? 'Tambah Artikel Baru'
                              : 'Edit Artikel',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        hintText: 'Masukkan judul artikel',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: currentCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Pilih Kategori'),
                      items:
                          const <String>[
                            'Kesejahteraan',
                            'UMKM',
                            'Keuangan',
                            'Pendidikan',
                            'BantuanSosial',
                            'Umum',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        modalSetState(() {
                          currentCategory = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                              type: FileType.image,
                              allowMultiple: false,
                            );
                        if (result != null && result.files.first.path != null) {
                          modalSetState(() {
                            _selectedImageFile = result.files.first;
                            currentImageUrl = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Gambar ${result.files.first.name} dipilih.',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pemilihan gambar dibatalkan.'),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          image:
                              _selectedImageFile != null &&
                                      _selectedImageFile!.path != null
                                  ? DecorationImage(
                                    image: FileImage(
                                      File(_selectedImageFile!.path!),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                  : (currentImageUrl != null &&
                                          currentImageUrl!.isNotEmpty
                                      ? DecorationImage(
                                        image: NetworkImage(currentImageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                      : null),
                        ),
                        child:
                            (_selectedImageFile == null &&
                                    (currentImageUrl == null ||
                                        currentImageUrl!.isEmpty))
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.cloud_upload,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      'Klik untuk upload gambar',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                                : null,
                      ),
                    ),
                    if (_selectedImageFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'File dipilih: ${_selectedImageFile!.name}',
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Konten',
                        hintText: 'Tulis konten artikel...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                      minLines: 4,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (titleController.text.isEmpty ||
                                  contentController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Judul dan konten tidak boleh kosong.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              String? finalImageUrl = currentImageUrl;
                              if (_selectedImageFile != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Mengunggah gambar...'),
                                  ),
                                );
                                finalImageUrl = await _cloudinaryService
                                    .uploadFile(
                                      platformFile: _selectedImageFile!,
                                      fileType: 'image',
                                    );
                                if (finalImageUrl == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Gagal mengunggah gambar. Artikel tidak disimpan.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                              }

                              await _saveArticleToFirestore(
                                article: article,
                                title: titleController.text,
                                content: contentController.text,
                                imageUrl: finalImageUrl,
                                category: currentCategory,
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Artikel & Berita'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter berdasarkan kategori.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  // PERBAIKAN: onChanged ini sekarang memanggil setState agar StreamBuilder re-evaluate
                  onChanged: (query) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari artikel...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryChip('Semua'),
                    _buildCategoryChip('Kesejahteraan'),
                    _buildCategoryChip('UMKM'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<EdukasiContent>>(
              stream: _getArticlesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada artikel ditemukan.'),
                  );
                }

                List<EdukasiContent> articles = snapshot.data!;
                // Terapkan filter dan pencarian pada data dari Firestore
                List<EdukasiContent> filteredAndSearchedArticles =
                    articles.where((article) {
                      final lowerQuery = _searchController.text.toLowerCase();
                      final titleMatches = article.title.toLowerCase().contains(
                        lowerQuery,
                      );
                      final tagMatches = article.tags.any(
                        (tag) => tag.toLowerCase().contains(lowerQuery),
                      );

                      bool categoryFilterMatches = true;
                      if (_selectedCategoryFilter != null &&
                          _selectedCategoryFilter != 'Semua') {
                        categoryFilterMatches = article.tags.contains(
                          '#$_selectedCategoryFilter',
                        );
                      }
                      return (titleMatches || tagMatches) &&
                          categoryFilterMatches;
                    }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredAndSearchedArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredAndSearchedArticles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _showArticleForm(article: article),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      article.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed:
                                        () =>
                                            _showArticleForm(article: article),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => _deleteArticleFromFirestore(
                                          article.id,
                                          article.title,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image:
                                      article.imageUrl.isNotEmpty
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              article.imageUrl,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                ),
                                child:
                                    article.imageUrl.isEmpty
                                        ? const Center(
                                          child: Text("Gambar tidak ada"),
                                        )
                                        : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kategori: ${article.tags.isNotEmpty ? article.tags.first.substring(1) : 'Tidak ada'}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Views: ${article.views}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showArticleForm(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Artikel Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedCategoryFilter == label,
      onSelected: (selected) {
        setState(() {
          _selectedCategoryFilter = selected ? label : null;
          // Pemicu rebuild untuk filter: panggil _searchController.text di onChanged TextField
          // atau jalankan _applyCategoryFilter di sini
          // Namun, karena _applyCategoryFilter ada di StreamBuilder,
          // cukup panggil setState di onChanged TextField
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color:
            _selectedCategoryFilter == label
                ? Theme.of(context).primaryColor
                : Colors.black,
      ),
    );
  }
}
