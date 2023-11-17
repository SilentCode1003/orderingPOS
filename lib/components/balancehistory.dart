import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uhordering/api/customercredit.dart';
import 'package:uhordering/repository/customhelper.dart';

class WalletHistoryPage extends StatefulWidget {
  final int customerid;
  final String customername;
  const WalletHistoryPage(
      {super.key, required this.customerid, required this.customername});

  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  List<Credit> balance = [];
  List<Widget> transactions = [];

  Helper helper = Helper();

  @override
  void initState() {
    // TODO: implement initState
    _getbalancehistory();
    super.initState();
  }

  Future<void> _getbalancehistory() async {
    try {
      final results = await CustomerCreditAPI()
          .getbalancehistory(widget.customerid.toString());
      final jsonData = json.encode(results['data']);

      if (results['msg'] == 'success') {
        setState(() {
          for (var data in json.decode(jsonData)) {
            int amount = data['amount'];
            balance.add(Credit(data['id'], data['creditid'], data['date'],
                amount.toDouble(), data['type']));
          }
        });
      }

      setState(() {
        transactions = List<Widget>.generate(
            balance.length,
            (index) => ListTile(
                  leading: Icon(Icons.receipt_long),
                  title: Text(
                    'TXN#: ${balance[index].historyid.toString().padLeft(9, '0')}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Date: ${balance[index].date}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    helper.formatAsCurrency(balance[index].amount),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  tileColor:
                      (balance[index].amount > 0) ? Colors.green : Colors.red.shade900,
                ));
      });
    } catch (e) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('$e'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-wallet'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: transactions,
        ),
      ),
    );
  }
}

class Credit {
  final int historyid;
  final int creditid;
  final String date;
  final double amount;
  final String type;

  Credit(this.historyid, this.creditid, this.date, this.amount, this.type);
}
