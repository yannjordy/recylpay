import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/mock_data.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 45250;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  double get balance => _balance;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WalletProvider() {
    _transactions = List.from(MockData.transactions);
  }

  Future<void> loadBalance() async {
    _balance = MockData.transactions
        .where((t) => t.type == 'deposit' || t.type == 'payment')
        .fold(0.0, (sum, t) => sum + t.amount)
      - MockData.transactions
          .where((t) => t.type == 'withdrawal' || t.type == 'commission')
          .fold(0.0, (sum, t) => sum + t.amount);
    if (_balance <= 0) _balance = 45250;
    notifyListeners();
  }

  Future<void> loadTransactions({int page = 1}) async {
    _isLoading = true;
    notifyListeners();
    _transactions = List.from(MockData.transactions);
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void clearAllTransactions() {
    _transactions.clear();
    notifyListeners();
  }

  Future<bool> requestWithdrawal(double amount, String phone) async {
    if (amount > _balance) {
      _error = 'Solde insuffisant';
      notifyListeners();
      return false;
    }
    _balance -= amount;
    _transactions.insert(0, TransactionModel(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_self',
      type: 'withdrawal',
      amount: amount,
      status: 'pending',
      reference: 'REF-${DateTime.now().millisecondsSinceEpoch}',
      description: 'Retrait $phone',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
    return true;
  }
}
