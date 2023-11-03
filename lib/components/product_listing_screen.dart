import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smallproject/api/products.dart';
import 'package:badges/badges.dart' as badges;
import 'package:smallproject/components/orders_screen.dart';

// void main() {
//   runApp(Products());
// }

// class Products extends StatefulWidget {
//   @override
//   State<Products> createState() => _ProductsState();
// }

// class _ProductsState extends State<Products> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ProductListingScreen(),
//     );
//   }
// }

class ProductListingScreen extends StatefulWidget {
  final int customerid;
  final double credit;
  const ProductListingScreen(
      {super.key, required this.customerid, required this.credit});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  Map<String, int> cart = {};
  int totalCartItems = 0;
  Map<String, double> totalPrices = {};
  List<Product> productlist = [];

  @override
  void initState() {
    _getproductlist();
    super.initState();
  }

  Future<void> _getproductlist() async {
    final results = await ProductAPI().getProduct();
    final jsonData = json.encode(results['data']);

    setState(() {
      for (var data in json.decode(jsonData)) {
        productlist.add(Product(
            data['description'], data['price'].toDouble(), data['image']));
      }
    });
  }

  void updateTotalCartItems() {
    int total = 0;
    cart.forEach((product, quantity) {
      total += quantity;
    });
    setState(() {
      totalCartItems = total;
    });
  }

  void addToCart(String product) {
    setState(() {
      if (cart.containsKey(product)) {
        cart[product] = (cart[product] ?? 0) + 1;
        totalPrices[product] = (totalPrices[product] ?? 0) +
            productlist.firstWhere((p) => p.name == product).price;
      } else {
        cart[product] = 1;
        totalPrices[product] =
            productlist.firstWhere((p) => p.name == product).price;
      }
      updateTotalCartItems(); // Update the total cart items
    });
  }

  void deductToCart(String product) {
    setState(() {
      if (cart.containsKey(product)) {
        final currentQuantity = cart[product] ?? 0;
        if (currentQuantity > 1) {
          cart[product] = currentQuantity - 1;
          totalPrices[product] = (totalPrices[product] ?? 0) -
              (productlist.firstWhere((p) => p.name == product).price);
        } else {
          cart.remove(product);
          totalPrices.remove(product);
        }
        updateTotalCartItems(); // Update the total cart items
      }
    });
  }

  void removeToCart(String product) {
    setState(() {
      if (cart.containsKey(product)) {
        cart.remove(product);
        totalPrices.remove(product);
        updateTotalCartItems(); // Update the total cart items
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Listing'),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: badges.Badge(
                  badgeContent: Text(totalCartItems.toString(),
                      style: const TextStyle(color: Colors.white)),
                  position: badges.BadgePosition.topEnd(top: -10, end: 0),
                  badgeStyle: badges.BadgeStyle(
                    shape: badges.BadgeShape.circle,
                    badgeColor: const Color.fromARGB(255, 226, 48, 48),
                    padding: const EdgeInsets.all(5),
                    borderRadius: BorderRadius.circular(4),
                    elevation: 0,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      print('customerid: ${widget.customerid}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderScreen(
                            cart: cart,
                            deductToCart: deductToCart,
                            productlist: productlist,
                            addToCart: addToCart,
                            removeToCart: removeToCart,
                            customerid: widget.customerid,
                            credit: widget.credit,
                            totalCartItems: totalCartItems,
                            totalPrices: totalPrices,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: productlist.length,
        itemBuilder: (context, index) {
          final product = productlist[index];
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
                      child: Image.memory(
                          base64Decode(productlist[index].imageAsset))),
                  Expanded(
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle the Add to Cart button action
                      addToCart(productlist[index].name);
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

// final List<Product> products = [
//   Product('Product 1', 9.99, 'assets/food1.jpeg'),
//   Product('Product 2', 19.99, 'assets/food2.jpeg'),
//   Product('Product 3', 29.99, 'assets/food3.jpeg'),
//   // Add more products with their respective image paths
// ];
