import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messages = <Map<String, String>>[
    {'from': 'ia', 'text': 'Olá! Quando integrar a IA, aqui você conversará com ela.'},
    {'from': 'user', 'text': 'Perfeito, vou integrar em breve.'},
  ];
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add({'from': 'user', 'text': text});
      _controller.clear();
      
      // placeholder: a resposta automática
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _messages.add({'from': 'ia', 'text': 'Resposta automática (integre sua IA aqui).'});
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat IA'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.sync_outlined))],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isUser = m['from'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.orangeAccent.withOpacity(0.95) : Colors.black.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m['text']!, style: TextStyle(color: isUser ? Colors.black : Colors.white70)),
                  ),
                );
              },
            ),
          ),

          // input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.black.withOpacity(0.06),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Escreva uma mensagem...',
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _sendMessage,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: const Color(0xFFF97316),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send_outlined),
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }
}