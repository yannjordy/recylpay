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

  static const double commissionRate = 0.02; // 2%

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

  Future<bool> deposit(double amount) async {
    if (amount <= 0) return false;
    final commission = amount * commissionRate;
    final netAmount = amount - commission;
    _balance += netAmount;
    _transactions.insert(0, TransactionModel(
      id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_self',
      type: 'deposit',
      amount: amount,
      status: 'completed',
      reference: 'DEP-${DateTime.now().millisecondsSinceEpoch}',
      description: 'Dépôt de ${amount.toInt()} FCFA (comm. ${commission.toInt()} FCFA)',
      createdAt: DateTime.now(),
    ));
    _transactions.insert(1, TransactionModel(
      id: 'com_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_self',
      type: 'commission',
      amount: commission,
      status: 'completed',
      reference: 'COM-${DateTime.now().millisecondsSinceEpoch}',
      description: 'Commission 2% sur dépôt',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
    return true;
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
