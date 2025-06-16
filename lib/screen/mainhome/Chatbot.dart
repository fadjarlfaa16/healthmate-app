import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool _isGenerating = false;

  CollectionReference get _messagesCollection {
    final String uid = auth.currentUser?.uid ?? 'unknown';
    return firestore.collection('chatRooms').doc(uid).collection('messages');
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty || _isGenerating) return;

    await _messagesCollection.add({
      'sender': 'user',
      'message': message,
      'timestamp': Timestamp.now(),
    });
    _messageController.clear();
    _scrollToBottom();

    setState(() {
      _isGenerating = true;
    });

    DocumentReference placeholderRef = await _messagesCollection.add({
      'sender': 'bot',
      'message': 'Generating response....',
      'timestamp': Timestamp.now(),
    });
    _scrollToBottom();

    try {
      final reply = await _fetchChatbotReply(message);
      await placeholderRef.delete();
      await _messagesCollection.add({
        'sender': 'bot',
        'message': reply,
        'timestamp': Timestamp.now(),
      });
      _scrollToBottom();
    } catch (e) {
      print("Error fetching bot reply: $e");
      await placeholderRef.update({'message': 'Error fetching reply'});
    } finally {
      setState(() {
        _isGenerating = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _fetchChatbotReply(String userMessage) async {
    final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");
    final scope =
        "By this prompt, please just answer related the health, diseases or drugs topic. If this prompt didnt ask anything about that please just answer it 'I'm just a chatbot spesifically in medical purpose, you can use ChatGPT or Gemini to ask this Question. Thank You     '";
    final headers = {
      "Authorization":
          "Bearer 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",
      "HTTP-Referer": "<YOUR_SITE_URL>",
      "X-Title": "<YOUR_SITE_NAME>",
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "model": "mistralai/devstral-small-2505:free",
      "messages": [
        {
          "role": "user",
          "content": [
            {"type": "text", "text": scope + userMessage},
          ],
        },
      ],
    });

    print("Sending API request with body: $body");
    final response = await http.post(url, headers: headers, body: body);
    print("API Response status: ${response.statusCode}");
    print("API Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String reply = data['choices'][0]['message']['content'] ?? "No reply";
      return reply;
    } else {
      throw Exception("API call failed with status: ${response.statusCode}");
    }
  }

  Future<void> _clearChat() async {
    try {
      final batch = firestore.batch();
      final snapshot = await _messagesCollection.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print("Error clearing chat: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error clearing chat: $e')));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear Chat',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _messagesCollection
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final sender = data['sender'] as String? ?? '';
                    final message = data['message'] as String? ?? '';
                    return Align(
                      alignment:
                          sender == 'user'
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              sender == 'user'
                                  ? Colors.blue[100]
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(message),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Opacity(
            opacity: _isGenerating ? 0.5 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Enter message',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed:
                        _isGenerating
                            ? null
                            : () => _sendMessage(_messageController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
