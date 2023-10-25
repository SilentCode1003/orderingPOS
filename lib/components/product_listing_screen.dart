import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductListingScreen(),
    );
  }
}

class ProductListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Listing'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to the shopping cart screen
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.all(5),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset(
                      product.imageAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle the Add to Cart button action
                    },
                    child: const Text('Add to Cart'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Product {
  final String name;
  final double price;
  final String imageAsset;

  Product(this.name, this.price, this.imageAsset);
}

final List<Product> products = [
  Product('Product 1', 9.99, 'assets/food1.jpeg'),
  Product('Product 2', 19.99, 'assets/food2.jpeg'),
  Product('Product 3', 29.99, 'assets/food3.jpeg'),
  // Add more products with their respective image paths
];
