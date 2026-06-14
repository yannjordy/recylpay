import '../models/transaction_model.dart';
import 'api_service.dart';

class WalletService {
  final ApiService _api = ApiService();

  Future<double> getBalance() async {
    final response = await _api.get('/wallet/balance');
    return (response.data['balance'] as num).toDouble();
  }

  Future<List<TransactionModel>> getTransactions({int page = 1, int limit = 20}) async {
    final response = await _api.get('/wallet/transactions', params: {
      'page': page,
      'limit': limit,
    });
    final data = response.data['data'] as List;
    return data.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TransactionModel> requestWithdrawal(double amount, String phone) async {
    final response = await _api.post('/wallet/withdraw', data: {
      'amount': amount,
      'phone': phone,
    });
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TransactionModel>> getPendingWithdrawals() async {
    final response = await _api.get('/wallet/withdrawals/pending');
    final data = response.data as List;
    return data.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
