import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/services/mock_data_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load Transactions
  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = MockDataService.instance.getMockTransactions(userId);
      _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'İşlem geçmişi yüklenemedi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add Transaction
  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  // Get Recent Transactions
  List<TransactionModel> getRecentTransactions({int limit = 10}) {
    return _transactions.take(limit).toList();
  }

  // Get Transactions by Type
  List<TransactionModel> getTransactionsByType(String type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

