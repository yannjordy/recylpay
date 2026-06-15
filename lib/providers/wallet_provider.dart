import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../services/mock_data.dart';
import '../services/notification_service.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 45250;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  double get balance => _balance;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const double commissionRate = 0.02;

  WalletProvider() {
    _transactions = List.from(MockData.transactions);
  }

  Future<void> loadBalance() async {
    _balance = MockData.transactions
        .where((t) => t.type == 'deposit' || t.type == 'payment_received')
        .fold(0.0, (sum, t) => sum + t.amount)
      - MockData.transactions
          .where((t) => t.type == 'withdrawal' || t.type == 'commission' || t.type == 'payment_sent')
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

  Future<Map<String, dynamic>?> findRecipient(String uniqueId) async {
    final normalized = uniqueId.startsWith('@') ? uniqueId : '@$uniqueId';
    try {
      final user = MockData.users.firstWhere((u) => u.uniqueId == normalized);
      return {'name': user.name, 'uniqueId': user.uniqueId, 'id': user.id};
    } catch (_) {
      return null;
    }
  }

  Future<bool> sendPayment(String recipientUniqueId, double amount) async {
    if (amount <= 0) {
      _error = 'Montant invalide';
      notifyListeners();
      return false;
    }
    if (amount > _balance) {
      _error = 'Solde insuffisant';
      notifyListeners();
      return false;
    }

    final normalized = recipientUniqueId.startsWith('@')
        ? recipientUniqueId
        : '@$recipientUniqueId';
    UserModel? maybeRecipient;
    try {
      maybeRecipient = MockData.users.firstWhere((u) => u.uniqueId == normalized);
    } catch (_) {}
    final recipient = maybeRecipient;
    if (recipient == null) {
      _error = 'Utilisateur introuvable';
      notifyListeners();
      return false;
    }

    final commission = (amount * commissionRate);
    final netAmount = amount - commission;

    _balance -= amount;

    _transactions.insert(0, TransactionModel(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_self',
      type: 'payment_sent',
      amount: amount,
      commission: commission,
      status: 'completed',
      reference: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      description: 'Paiement à ${recipient.name} (${recipient.uniqueId})',
      createdAt: DateTime.now(),
    ));

    MockData.transactions.insert(0, TransactionModel(
      id: 'rcv_${DateTime.now().millisecondsSinceEpoch}',
      userId: recipient.id,
      type: 'payment_received',
      amount: netAmount,
      commission: commission,
      status: 'completed',
      reference: 'RCV-${DateTime.now().millisecondsSinceEpoch}',
      description: 'Paiement reçu (comm. ${commission.toInt()} FCFA)',
      createdAt: DateTime.now(),
    ));

    final idx = MockData.users.indexWhere((u) => u.id == recipient.id);
    if (idx != -1) {
      MockData.users[idx] = MockData.users[idx].copyWith(
        balance: MockData.users[idx].balance + netAmount,
      );
    }

    NotificationService().addNotification(AppNotification(
      id: 'notif_pay_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Paiement reçu',
      body:
          'Vous avez reçu ${netAmount.toInt()} FCFA (commission: ${commission.toInt()} FCFA)',
      icon: Icons.wallet_rounded,
      color: const Color(0xFFF1C40F),
    ));

    _error = null;
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
