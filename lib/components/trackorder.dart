import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smallproject/api/customerorder.dart';

class TrackOrderPage extends StatefulWidget {
  final int customerid;
  final String customername;

  const TrackOrderPage(
      {super.key, required this.customerid, required this.customername});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  final List<Product> products = [
    Product(
      name: "Combo Meal",
      description: 'Breakfast - Coffee and others',
      imageAsset: "",
      price: 19.99,
    ),
    Product(
      name: "Borgir",
      description: 'Double patty',
      imageAsset: "",
      price: 24.99,
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    _getorderhistory();
    super.initState();
  }

  Future<void> _getorderhistory() async {
    try {
      final results =
          await CustomerOrderAPI().orderhistory(widget.customerid.toString());
      final jsonData = json.encode(results['data']);
    } catch (e) {}
  }
 
  void showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 825, // Set your desired height
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Text('Order ID# 000000'),
                    const Text(
                      'DD Mmm, hh:mm',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          alignment: Alignment.center,
                          width: 75,
                          height: 23,
                          color: Colors.green,
                          child: const Center(
                            child: Text(
                              'Status',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 11.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          height: 190,
                          color: Colors.grey.shade200,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Text('1x'),
                                  title: Text(product.name),
                                  trailing: Text(
                                    '₱${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                                const Text('data'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 13, bottom: 13),
                      child: Divider(height: 3),
                    ),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Subtotal',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                                color: Colors.grey),
                          ),
                        ),
                        SizedBox(width: 30),
                        Text(
                          '₱ total',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 13, bottom: 13),
                      child: Divider(height: 3),
                    ),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Payment Type:',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                                color: Colors.grey),
                          ),
                        ),
                        SizedBox(width: 30),
                        Text(
                          'Paymayuhh',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  Product product = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                    ),
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Image.asset(
                                          product.imageAsset,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              product.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                            ),
                                          ),
                                          const SizedBox(width: 30),
                                          Text(
                                            'Price: \₱${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          'DD Mmm, hh:mm',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          product.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showProductDetails(context, product);
                                    },
                                    child: const Text('Detailed View'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final String imageAsset;
  final double price;
  String description;

  Product({
    required this.name,
    required this.imageAsset,
    required this.price,
    required this.description,
  });
}
