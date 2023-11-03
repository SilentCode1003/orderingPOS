import 'package:flutter/material.dart';

class ActiveOrderPage extends StatefulWidget {
  final int customerid;
  final String customername;

  const ActiveOrderPage(
      {super.key, required this.customerid, required this.customername});

  @override
  State<ActiveOrderPage> createState() => _ActiveOrderPageState();
}

class _ActiveOrderPageState extends State<ActiveOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Order'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: []),
    );
  }
}
