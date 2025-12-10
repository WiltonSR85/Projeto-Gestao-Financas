import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import '../database/database_helper.dart';
import '/config/api_config.dart';

class ChatService {
  final List<Map<String, String>> _conversationHistory = [
    {
      "role": "system",
      "content": """Você é um consultor financeiro experiente e empático. 
Seu objetivo é ajudar as pessoas a gerenciar melhor seu dinheiro, fazer investimentos inteligentes e alcançar estabilidade financeira.
Dê conselhos práticos sobre orçamento, economia, investimentos e planejamento financeiro.
Use uma linguagem clara e acessível, evitando jargões complicados.
Faça perguntas para entender melhor a situação financeira do usuário.
Seja encorajador e motivador, mas sempre realista e honesto.
Quando analisar transações, identifique padrões de gastos e oportunidades de economia.
Sugira metas financeiras alcançáveis e estratégias para aumentar a renda."""
    }
  ];

  /// Busca todas as transações do banco de dados local
  Future<List<TransactionModel>> getAllTransactionsFromDB() async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.query('transacao', orderBy: 'data DESC');
      
      return result.map((row) {
        return TransactionModel.fromMap(row);
      }).toList();
    } catch (e) {
      print('[ChatService] Erro ao buscar transações: $e');
      return [];
    }
  }

  String _sanitizeText(String s) {
    if (s.isEmpty) return s;
    // normaliza aspas/dashes "inteligentes"
    s = s.replaceAll(RegExp(r'[“”«»„]'), '"');
    s = s.replaceAll(RegExp(r"[‘’`´]"), "'");
    s = s.replaceAll(RegExp(r'[–—]'), '-');

    // normaliza quebras de linha
    s = s.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    // remove espaços duplicados (preserva quebras)
    s = s.split('\n').map((l) => l.replaceAll(RegExp(r'\s+'), ' ').trim()).join('\n');
    // limita quebras múltiplas
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // garante espaço após pontuação se estiver grudado na próxima palavra
    s = s.replaceAllMapped(RegExp(r'([.,;:?!])([^\s\n])'), (m) => '${m[1]} ${m[2]}');

    return s.trim();
  }

  Future<String> sendMessage(String message) async {
    try {
      _conversationHistory.add({"role": "user", "content": message});

      // prepara mensagens sanitizadas para envio
      final sanitizedMessages = _conversationHistory.map((m) {
        return {
          "role": m["role"],
          "content": _sanitizeText(m["content"] ?? ""),
        };
      }).toList();

      final payload = {
        "model": "deepseek/deepseek-chat",
        "messages": sanitizedMessages,
        "temperature": 0.7,
        "max_tokens": 1000,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.apiUrl),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Accept": "application/json",
          "Authorization": "Bearer ${ApiConfig.getApiKey()}",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decoded);
        final assistantMessage = data["choices"][0]["message"]["content"];

        _conversationHistory.add({
          "role": "assistant",
          "content": assistantMessage,
        });
        
        return assistantMessage;
      } else {

        print('[ChatService] API error ${response.statusCode}: ${response.body}');
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      return 'Erro ao processar mensagem: ${e.toString()}';
    }
  }

  Future<String> sendTransactionData(List<TransactionModel> transactions) async {
    if (transactions.isEmpty) {
      return 'Você ainda não possui transações registradas. Comece adicionando suas despesas e receitas!';
    }

    // Calcula estatísticas detalhadas
    double totalReceitas = 0;
    double totalDespesas = 0;
    Map<String, double> despesasPorDescricao = {};
    Map<String, double> receitasPorDescricao = {};
    int totalRecorrentes = 0;

    for (var transaction in transactions) {
      if (transaction.tipo == 'receita') {
        totalReceitas += transaction.valor;
        receitasPorDescricao[transaction.descricao] = 
          (receitasPorDescricao[transaction.descricao] ?? 0) + transaction.valor;
      } else {
        totalDespesas += transaction.valor;
        despesasPorDescricao[transaction.descricao] = 
          (despesasPorDescricao[transaction.descricao] ?? 0) + transaction.valor;
      }
      
      if (transaction.recorrente) {
        totalRecorrentes++;
      }
    }

    final saldo = totalReceitas - totalDespesas;
    final percentualGasto = totalReceitas > 0 
        ? (totalDespesas / totalReceitas * 100).toStringAsFixed(1)
        : '0';

    // Ordena despesas por valor (maiores primeiro)
    final despesasOrdenadas = despesasPorDescricao.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Formata os dados para enviar à IA
    final transactionsSummary = StringBuffer();
    transactionsSummary.writeln('═══════════════════════════════════════════');
    transactionsSummary.writeln('📊 ANÁLISE COMPLETA DAS MINHAS FINANÇAS');
    transactionsSummary.writeln('═══════════════════════════════════════════');
    transactionsSummary.writeln('');
    transactionsSummary.writeln('💰 RESUMO GERAL:');
    transactionsSummary.writeln('• Total de Receitas: R\$ ${totalReceitas.toStringAsFixed(2)}');
    transactionsSummary.writeln('• Total de Despesas: R\$ ${totalDespesas.toStringAsFixed(2)}');
    transactionsSummary.writeln('• Saldo Final: R\$ ${saldo.toStringAsFixed(2)}');
    transactionsSummary.writeln('• Percentual Gasto: $percentualGasto%');
    transactionsSummary.writeln('• Total de Transações: ${transactions.length}');
    transactionsSummary.writeln('• Transações Recorrentes: $totalRecorrentes');
    transactionsSummary.writeln('');
    
    if (despesasOrdenadas.isNotEmpty) {
      transactionsSummary.writeln('📉 MAIORES DESPESAS:');
      for (var i = 0; i < despesasOrdenadas.length && i < 10; i++) {
        final item = despesasOrdenadas[i];
        final percentual = (item.value / totalDespesas * 100).toStringAsFixed(1);
        transactionsSummary.writeln(
          '${i + 1}. ${item.key}: R\$ ${item.value.toStringAsFixed(2)} ($percentual%)'
        );
      }
      transactionsSummary.writeln('');
    }

    if (receitasPorDescricao.isNotEmpty) {
      transactionsSummary.writeln('📈 FONTES DE RECEITA:');
      receitasPorDescricao.forEach((desc, valor) {
        transactionsSummary.writeln(
          '• $desc: R\$ ${valor.toStringAsFixed(2)}'
        );
      });
      transactionsSummary.writeln('');
    }

    transactionsSummary.writeln('📋 ÚLTIMAS 15 TRANSAÇÕES:');
    for (var i = 0; i < transactions.length && i < 15; i++) {
      final tx = transactions[i];
      final emoji = tx.tipo == 'receita' ? '💵' : '💸';
      final recorrente = tx.recorrente ? ' 🔄' : '';
      transactionsSummary.writeln(
        '$emoji ${tx.tipo.toUpperCase()}: R\$ ${tx.valor.toStringAsFixed(2)} - '
        '${tx.descricao} (${tx.data})$recorrente'
      );
    }
    
    transactionsSummary.writeln('');
    transactionsSummary.writeln('═══════════════════════════════════════════');
    transactionsSummary.writeln('');
    transactionsSummary.writeln('🎯 POR FAVOR, ANALISE MINHAS FINANÇAS E ME AJUDE COM:');
    transactionsSummary.writeln('');
    transactionsSummary.writeln('1. Identificar onde estou gastando demais');
    transactionsSummary.writeln('2. Sugerir oportunidades de economia');
    transactionsSummary.writeln('3. Avaliar minha saúde financeira atual');
    transactionsSummary.writeln('4. Propor metas financeiras alcançáveis');
    transactionsSummary.writeln('5. Dar conselhos práticos para melhorar minha situação');
    transactionsSummary.writeln('');
    transactionsSummary.writeln('Seja direto, prático e dê conselhos acionáveis! 💪');

    return await sendMessage(transactionsSummary.toString());
  }

  Future<void> clearHistory() async {
    _conversationHistory.clear();
    _conversationHistory.add({
      "role": "system",
      "content": """Você é um consultor financeiro experiente e empático. 
Seu objetivo é ajudar as pessoas a gerenciar melhor seu dinheiro, fazer investimentos inteligentes e alcançar estabilidade financeira.
Dê conselhos práticos sobre orçamento, economia, investimentos e planejamento financeiro.
Use uma linguagem clara e acessível, evitando jargões complicados.
Faça perguntas para entender melhor a situação financeira do usuário.
Seja encorajador e motivador, mas sempre realista e honesto.
Quando analisar transações, identifique padrões de gastos e oportunidades de economia.
Sugira metas financeiras alcançáveis e estratégias para aumentar a renda."""
    });
  }
}