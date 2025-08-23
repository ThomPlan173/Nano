import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final String apiKey =
      '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';

  @override
  void initState() {
    super.initState();
    loadMessages().then((_) {
      if (_messages.isEmpty) addNanoWelcomeMessage();
    });
  }

  Future<void> saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMessages = jsonEncode(_messages);
    await prefs.setString('chat_messages', jsonMessages);
  }

  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMessages = prefs.getString('chat_messages');
    if (jsonMessages != null) {
      final List<dynamic> decoded = jsonDecode(jsonMessages);
      setState(() {
        _messages.clear();
        _messages.addAll(decoded.map((msg) => Map<String, String>.from(msg)));
      });
    }
  }

  void addNanoWelcomeMessage() {
    _addMessage({
      'role': 'assistant',
      'content':
          'Bienvenue Maître ✨\nJe suis Nano. Posez-moi une question, je suis à votre service.',
    });
  }

  Future<void> clearConversation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages'); // Supprimer de la mémoire
    setState(() {
      _messages.clear(); // Nettoyer l'affichage
      addNanoWelcomeMessage(); // Ajouter message d'accueil
    });
  }


  void _addMessage(Map<String, String> message) {
    setState(() {
      _messages.add(message);
    });
    saveMessages();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> sendMessage(String userInput) async {
    if (userInput.trim().isEmpty) return;

    _addMessage({'role': 'user', 'content': userInput});
    _controller.clear();

    final messagesToSend = [
      {
        'role': 'system',
        'content':
            'Tu es Nano, une IA élégante qui appelle l’utilisateur "Maître", qui lui obéit et le protège.',
      },
      ..._messages.takeLast(6),
    ];

    try {
      final res = await http.post(
        Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "openai/gpt-3.5-turbo",
          "messages": messagesToSend,
        }),
      );

      if (res.statusCode == 200) {
        final content = jsonDecode(
          res.body,
        )["choices"][0]["message"]["content"];
        _addMessage({'role': 'assistant', 'content': content});
      } else {
        _addMessage({
          'role': 'assistant',
          'content': 'Erreur ${res.statusCode}, Maître…',
        });
      }
    } catch (e) {
      _addMessage({
        'role': 'assistant',
        'content': 'Nano a crashé, Maître… 😢',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[950],
      appBar: AppBar(
        title: Text("Nano ✨"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: 'Nettoyer',
            onPressed: () {
              clearConversation();
            },
          ),
        ],
        backgroundColor: Colors.grey[850],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[600] : Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: Colors.grey),
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Demande quelque chose à Nano...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension<T> on List<T> {
  List<T> takeLast(int n) => skip(length > n ? length - n : 0).toList();
}
