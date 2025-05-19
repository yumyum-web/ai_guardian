import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import '../services/gemini_service.dart';

class ChatBotScreen extends StatefulWidget {
  final String geminiApiKey;
  const ChatBotScreen({super.key, required this.geminiApiKey});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late final GeminiService _geminiService;
  final TextEditingController _controller = TextEditingController();
  List<Content> _chat = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(widget.geminiApiKey);
    _loadChat();
  }

  Future<void> _loadChat() async {
    final chat = await _geminiService.loadChatHistory();
    setState(() => _chat = chat);
  }

  Future<void> _saveChat() async {
    await _geminiService.saveChatHistory(_chat);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final modelContent = await _geminiService.sendMessage(_chat, text);
      if (modelContent != null) {
        setState(() {
          _chat.add(Content(parts: [Part.text(text)], role: 'user'));
          _chat.add(modelContent);
          _controller.clear();
        });
      }
    } catch (e) {
      print("Error sending message: $e");
      _showError('Failed to send message');
    }
    setState(() => _loading = false);
  }

  Future<void> _startNewChat() async {
    await _geminiService.clearChatHistory();
    setState(() => _chat = []);
  }

  Future<void> _showError(String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Bot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.recycling),
            tooltip: 'Start New Chat',
            onPressed: _startNewChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chat.length,
              itemBuilder: (context, i) {
                final msg = _chat[i];
                final isUser = msg.role == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isUser
                              ? Theme.of(context).primaryColor
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (msg.parts != null &&
                              msg.parts!.isNotEmpty &&
                              msg.parts!.first is TextPart)
                          ? (msg.parts!.first as TextPart).text
                          : '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_loading,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _loading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _saveChat();
    super.dispose();
  }
}
