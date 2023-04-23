import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learningflutter/components/transaction_item.dart';

import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final void Function(String) onRemove;
  TransactionList(this.transactions, this.onRemove);

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
        ? LayoutBuilder(
            builder: (ctx, constraint) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    child: Text('Nenhuma Transação Cadastrada!',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                      height: constraint.maxHeight * 0.6,
                      child: Image.asset(
                        "assets/images/waiting.png",
                        fit: BoxFit.cover,
                      )),
                ],
              );
            },
          )
        : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (ctx, index) {
              final tr = transactions[index];
              return TransactionItem(tr: tr, onRemove: onRemove);
            },
          );
  }
}
