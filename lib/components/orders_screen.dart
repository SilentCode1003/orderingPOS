import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smallproject/api/customerorder.dart';
import 'package:smallproject/components/product_listing_screen.dart';

class OrderScreen extends StatefulWidget {
  final Map<String, int> cart;
  final Function(String) deductToCart;
  final Function(String) addToCart;
  final Function(String) removeToCart;
  final List<Product> products;
  final int customerid;
  const OrderScreen({
    super.key,
    required this.cart,
    required this.deductToCart,
    required this.addToCart,
    required this.products,
    required this.removeToCart,
    required this.customerid
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  double total = 0.0;
  String paymenttype = '';


  Future<void> _order() async {
    final results = await CustomerOrderAPI()
        .order(widget.customerid, widget.products, total, paymenttype);
    final jsonData = json.encode(results['data']);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cartItems = [];
    for (int index = 0; index < widget.cart.length; index++) {
      String product = widget.cart.keys.elementAt(index);
      int? quantity = widget.cart[product];
      Product? productData = widget.products.firstWhere(
        (p) => p.name == product,
        orElse: () => Product("Product Not Found", 0.0, ""),
      );

      if (productData != null) {
        double totalPrice = productData.price * quantity!;
        total += totalPrice;
        cartItems.add(Card(
          elevation: 3,
          margin: const EdgeInsets.all(5),
          child: ListTile(
            title: Text('$product (QTY $quantity)'),
            subtitle: Text('Total Price: \₱${totalPrice.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.addToCart(product);
                    setState(() {});
                  },
                  child: const Text("+"),
                ),
                const SizedBox(
                    width: 5), // Add some spacing between the buttons
                ElevatedButton(
                  onPressed: () {
                    widget.deductToCart(product);
                    setState(() {});
                  },
                  child: const Text("-"),
                ),
                const SizedBox(
                    width: 16), // Add some spacing between the buttons
                ElevatedButton.icon(
                    onPressed: () {
                      widget.removeToCart(product);
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    label: const Text('REMOVE')),
              ],
            ),
          ),
        ));
      } else {
        cartItems.add(
          Card(
            elevation: 3,
            margin: const EdgeInsets.all(5),
            child: ListTile(
              title: const Text('Product Not Found'),
              subtitle: const Text('Total Price: \₱0.00'),
              trailing: ElevatedButton(
                onPressed: () {
                  widget.deductToCart(product);
                  setState(() {});
                },
                child: const Text("Remove"),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Items'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: cartItems,
            ),
          ),
          ListTile(
            title: const Text('Total',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Total Price: \₱${total.toStringAsFixed(2)}'),
            trailing: Container(
                constraints: const BoxConstraints(
                  minWidth: 200.0,
                  maxWidth: 380.0,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _order();
                  },
                  icon: const Icon(Icons.paid),
                  label: const Text('Review Payment & Address'),
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                    maximumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
