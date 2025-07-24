import 'package:flutter/material.dart';
import '../backend_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.service});

  final BackendService service;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class ChatMessage {
  ChatMessage(this.text, {this.isUser = false});
  final String text;
  final bool isUser;
}

class _ChatPageState extends State<ChatPage> {
  final _messages = <ChatMessage>[];
  final _controller = TextEditingController();
  Stream<String>? _stream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length + (_stream != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.isUser ? Colors.blue : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(color: msg.isUser ? Colors.white : Colors.black),
                      ),
                    ),
                  );
                } else {
                  return StreamBuilder<String>(
                    stream: _stream,
                    builder: (context, snapshot) {
                      final text = snapshot.data ?? '';
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(text),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(hintText: 'Say something'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text, isUser: true));
      _controller.clear();
      _stream = widget.service.chatStream(text);
    });
    _stream!.last.then((finalText) {
      setState(() {
        _messages.add(ChatMessage(finalText));
        _stream = null;
      });
    });
  }
}
