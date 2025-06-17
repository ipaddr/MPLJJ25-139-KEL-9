import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  DialogFlowtter? dialogFlowtter;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _initializeDialogFlowtter();
  }

  Future<void> _initializeDialogFlowtter() async {
    try {
      // Membaca kredensial dari file assets
      String jsonString = await rootBundle.loadString(
        'assets/credentials/sejahterahub-e5c711aeaa68.json',
      );
      Map<String, dynamic> jsonCredentials = jsonDecode(jsonString);

      DialogAuthCredentials credentials = DialogAuthCredentials.fromJson(
        jsonCredentials,
      );

      dialogFlowtter = DialogFlowtter(
        credentials: credentials,
        sessionId: 'sejahtera_hub_user_session',
      );
    } catch (e) {
      print('Error initializing DialogFlowtter: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menginisialisasi chatbot: $e')),
      );
    }
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    if (dialogFlowtter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chatbot belum siap, coba sebentar lagi.'),
        ),
      );
      return;
    }

    setState(() {
      messages.add({'message': text, 'isUser': true});
      _messageController.clear();
    });

    try {
      final DetectIntentResponse response = await dialogFlowtter!.detectIntent(
        queryInput: QueryInput(text: TextInput(text: text)),
      );

      final String? responseText = response.message?.text?.text?.join(' ');

      setState(() {
        messages.add({
          'message':
              responseText?.isNotEmpty == true
                  ? responseText!
                  : 'Maaf, tidak ada respons dari bot.',
          'isUser': false,
        });
      });
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        messages.add({
          'message':
              'Terjadi kesalahan saat menghubungi bot. Mohon coba lagi nanti. ($e)',
          'isUser': false,
        });
      });
    }
  }

  @override
  void dispose() {
    dialogFlowtter?.dispose();
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
              itemCount: messages.length,
              itemBuilder: (context, index) {
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
