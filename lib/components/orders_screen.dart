import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Order> orders = getOrderData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: orders.isEmpty
          ? Center(child: Text('No orders available.'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Order ID: ${order.orderId}'),
                  subtitle: Text('Total: \$${order.total.toStringAsFixed(2)}'),
                );
              },
            ),
    );
  }
}

class Order {
  final int orderId;
  final double total;

  Order(this.orderId, this.total);
}

List<Order> getOrderData() {
  return [
    Order(1, 25.99),
    Order(2, 49.99),
  ];
}
