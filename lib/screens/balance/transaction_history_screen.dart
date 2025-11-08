import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr['transactionHistory']!),
      ),
      body: transactionProvider.transactions.isEmpty
          ? Builder(
              builder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: AppColors.getIconColor(context)),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz işlem geçmişi yok',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: transactionProvider.transactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionTile(
                  transactionProvider.transactions[index],
                );
              },
            ),
    );
  }

  Widget _buildTransactionTile(TransactionModel transaction) {
    return Builder(
      builder: (context) {
        final isCredit = transaction.isCredit;
        final icon = isCredit ? Icons.add_circle : Icons.remove_circle;
        final color = isCredit ? AppColors.success : AppColors.error;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getBorder(context)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatDate(transaction.createdAt, 'MMM dd, yyyy HH:mm'),
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isCredit ? "+" : ""}${Helpers.formatCurrency(transaction.amount)}',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

