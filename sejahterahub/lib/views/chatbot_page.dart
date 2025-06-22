// lib/views/chatbot_page.dart
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // <-- Import Gemini API// Digunakan untuk rootBundle, jika API Key dari assets

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  // Ganti dengan API Key Gemini Anda dari Google AI Studio
  // CATATAN PENTING: Jangan menyimpan API Key langsung di kode untuk aplikasi produksi yang akan dirilis!
  // Pertimbangkan menggunakan variabel lingkungan, server backend, atau Firebase Functions.
  final String _geminiApiKey =
      "AIzaSyDmifNGDSAOBlLyCtKD_akxl73z_a88cas"; // <--- GANTI DENGAN API KEY ANDA

  late final GenerativeModel _model; // Deklarasi model Gemini
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool _isBotTyping = false; // Untuk indikator bot sedang membalas

  @override
  void initState() {
    super.initState();
    // Inisialisasi model Gemini di initState
    _model = GenerativeModel(
      model:
          'gemini-1.5-flash', // Anda bisa mencoba 'gemini-pro-vision' jika ingin input gambar
      apiKey: _geminiApiKey,
    );
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    // Tambahkan pesan pengguna ke daftar
    setState(() {
      messages.add({'message': text, 'isUser': true});
      _messageController.clear();
      _isBotTyping = true; // Set bot sedang mengetik
    });

    try {
      // Buat konten untuk dikirim ke Gemini
      final content = [Content.text(text)];

      // Kirim pesan ke model Gemini
      final response = await _model.generateContent(content);

      // Ambil teks respons dari Gemini
      final String? responseText = response.text;

      setState(() {
        messages.add({
          'message':
              responseText?.isNotEmpty == true
                  ? responseText!
                  : 'Maaf, saya tidak bisa memberikan respons saat ini.',
          'isUser': false,
        });
        _isBotTyping = false; // Bot selesai mengetik
      });
    } catch (e) {
      print('Error communicating with Gemini: $e');
      setState(() {
        messages.add({
          'message':
              'Terjadi kesalahan saat menghubungi bot. Mohon coba lagi nanti. ($e)',
          'isUser': false,
        });
        _isBotTyping = false; // Bot selesai mengetik
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot Konsultasi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount:
                  messages.length +
                  (_isBotTyping ? 1 : 0), // Tambah item untuk indikator typing
              itemBuilder: (context, index) {
                if (_isBotTyping && index == messages.length) {
                  return Align(
                    // Indikator bot sedang mengetik
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Text(
                        'Bot sedang mengetik...',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  );
                }

                final message = messages[index];
                final String messageText =
                    message['message'] is String
                        ? message['message']
                        : message['message'].toString();

                return Align(
                  alignment:
                      message['isUser']
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color:
                          message['isUser']
                              ? Colors.blue[100]
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      messageText,
                      style: TextStyle(
                        color:
                            message['isUser']
                                ? Colors.blue[900]
                                : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan Anda...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _sendMessage(_messageController.text),
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
