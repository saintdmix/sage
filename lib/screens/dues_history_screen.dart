import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../cubits/app_cubit.dart';
import '../theme/app_theme.dart';

class DuesHistoryScreen extends StatelessWidget {
  const DuesHistoryScreen({super.key});

  void _showPaymentDialog(BuildContext context) {
    final state = context.read<AppCubit>().state;
    final account = state.accountDetails;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Make a Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please upload a receipt after you have made the transfer to this account:'),
                const SizedBox(height: 16),
                if (account != null) ...[
                  Text('Bank: ${account['bank_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Account Name: ${account['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Account Number: ${account['account_number']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.wineColor)),
                ] else
                  const Text('Account details unavailable.'),
                const SizedBox(height: 24),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount Paid (₦)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final amountText = amountController.text;
                final amount = double.tryParse(amountText) ?? 0.0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                _pickReceipt(context, amount);
              },
              child: const Text('I have made the payment'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickReceipt(BuildContext context, double amount) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      if (context.mounted) {
        context.read<AppCubit>().uploadReceiptAndSubmitDue(image, amount);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dues History'),
      ),
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.duesHistory.isEmpty) {
            return const Center(child: Text('No dues paid yet.'));
          }

          return ListView.builder(
            itemCount: state.duesHistory.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final due = state.duesHistory[index];
              final status = due['status'] ?? 'Pending';
              final color = status == 'Confirmed' ? Colors.green : Colors.orange;

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.wineColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.receipt, color: AppTheme.wineColor),
                  ),
                  title: Text(
                    '₦${(due['amount'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text('Date: ${due['date'] ?? 'Unknown'}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPaymentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
