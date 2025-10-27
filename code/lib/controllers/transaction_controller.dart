import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

class TransactionController with ChangeNotifier {
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  void addTransaction(TransactionModel tx) {
    _transactions.add(tx);
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  double get totalAmount =>
      _transactions.fold(0.0, (sum, t) => sum + t.amount);
}