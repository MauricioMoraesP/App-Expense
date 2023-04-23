import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'components/chart.dart';
import 'components/transaction_list.dart';
import 'models/transaction.dart';
import 'package:intl/intl.dart';
import 'components/transaction_form.dart';

main() => runApp(ExpensesApp());

class ExpensesApp extends StatelessWidget {
  ExpensesApp({Key? key}) : super(key: key);
  final ThemeData tema = ThemeData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
/*
Criação do Tema base do app.
*/
      theme: ThemeData(
        colorScheme: tema.colorScheme.copyWith(
            primary: Colors.purple, secondary: Colors.amber, error: Colors.red),
        textTheme: ThemeData.light().textTheme.copyWith(
              titleSmall: TextStyle(
                fontFamily: 'QuickSand',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              labelLarge:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              titleLarge: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];
  bool _showChart = false;
// Obter a varíavel privada.
  bool get showChart {
    return _showChart;
  }

// Filter que realiza uma busca nas últimas adições em listas de despesa.
  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
        Duration(days: 7),
      ));
    }).toList();
  }

//Esta função serve para adicionar instanciar objetos de acorodo com o modelo Transactions.
  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );
// Esta função serve para retornar uma mudança de estado no aplicativo que é adicionar
//novos dados para a lista
    setState(() {
      _transactions.add(newTransaction);
    });
    // é para poder fechar a rota criada pelo modal/ fomulário criado para criar os novos objetos.
    Navigator.of(context).pop();
  }

// Para deletar intens da lista
  _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  Widget _getIconButton(IconData icon, Function() fn) {
    return Platform.isIOS
        ? GestureDetector(onTap: fn, child: Icon(icon))
        : IconButton(icon: Icon(icon), onPressed: fn);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    bool isLandScape = mediaQuery.orientation == Orientation.landscape;
    final iconList = Platform.isIOS ? CupertinoIcons.refresh : Icons.list;
    final charList = Platform.isIOS ? CupertinoIcons.refresh : Icons.show_chart;

    final actions = [
      _getIconButton(
        Platform.isIOS ? CupertinoIcons.add : Icons.add,
        () => _openTransactionFormModal(context),
      ),
      if (isLandScape)
        _getIconButton(_showChart ? iconList : charList, () {
          setState(() {
            _showChart = !_showChart;
          });
        }),
    ];
    final appBar = AppBar(
      title: const Text(
        'Despesas Pessoais',
      ),
      actions: actions,
    );
    final availabelHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    final bodyPage = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showChart || !isLandScape)
              Container(
                height: availabelHeight * (isLandScape ? 0.8 : 0.30),
                child: Chart(_recentTransactions),
              ),
            if (!_showChart || !isLandScape)
              Container(
                  alignment: Alignment.center,
                  height: availabelHeight * (isLandScape ? 1 : 0.70),
                  child: TransactionList(
                    _transactions,
                    _deleteTransaction,
                  )),
          ],
        ),
      ),
    );
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text('Despesas Pessoais'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              ),
            ),
            child: bodyPage,
          )
        : Scaffold(
            appBar: appBar,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_showChart || !isLandScape)
                    Container(
                      height: availabelHeight * (isLandScape ? 0.8 : 0.30),
                      child: Chart(_recentTransactions),
                    ),
                  if (!_showChart || !isLandScape)
                    Container(
                        alignment: Alignment.center,
                        height: availabelHeight * (isLandScape ? 1 : 0.70),
                        child: TransactionList(
                          _transactions,
                          _deleteTransaction,
                        )),
                ],
              ),
            ),
            floatingActionButton: Platform.isMacOS
                ? Container()
                : FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () => _openTransactionFormModal(context),
                  ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
