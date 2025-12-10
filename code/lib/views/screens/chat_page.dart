import 'package:flutter/material.dart';
import '/services/chat_service.dart';
import '/models/transaction_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _chatService = ChatService();
  final _messages = <Map<String, dynamic>>[];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addMessage('ia', 'Olá! Sou seu consultor financeiro pessoal. Como posso ajudá-lo a melhorar sua saúde financeira hoje?');
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String from, String text) {
    setState(() {
      _messages.add({'from': from, 'text': text, 'timestamp': DateTime.now()});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;
    
    _addMessage('user', text);
    _controller.clear();
    
    setState(() => _isLoading = true);

    try {
      final response = await _chatService.sendMessage(text);
      _addMessage('ia', response);
    } catch (e) {
      _addMessage('ia', 'Desculpe, ocorreu um erro ao processar sua mensagem. Tente novamente.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendTransactionData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    
    try {
      // Busca TODAS as transações do banco de dados
      final transactions = await _chatService.getAllTransactionsFromDB();
      
      if (transactions.isEmpty) {
        _addMessage('ia', 'Você ainda não possui transações registradas. Comece adicionando suas receitas e despesas para que eu possa analisar suas finanças! 💰');
        setState(() => _isLoading = false);
        return;
      }

      _addMessage('user', '📊 Enviando dados das minhas transações para análise...');
      
      final response = await _chatService.sendTransactionData(transactions);
      _addMessage('ia', response);
    } catch (e) {
      _addMessage('ia', 'Erro ao analisar suas transações: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Conversa'),
        content: const Text('Deseja realmente limpar todo o histórico da conversa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _chatService.clearHistory();
      setState(() {
        _messages.clear();
        _addMessage('ia', 'Olá! Sou seu consultor financeiro pessoal. Como posso ajudá-lo a melhorar sua saúde financeira hoje?');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultor Financeiro IA'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _sendTransactionData,
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Analisar Transações',
          ),
          IconButton(
            onPressed: _clearHistory,
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Limpar Conversa',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
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
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser 
                        ? Colors.orangeAccent.withOpacity(0.95) 
                        : Colors.black.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.black : Colors.white70,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Pensando...', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.black.withOpacity(0.06),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'Escreva uma mensagem...',
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.12),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: const Color(0xFFF97316),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.send_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}