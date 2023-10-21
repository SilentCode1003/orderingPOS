import 'package:flutter/material.dart';
import 'package:smallproject/orders_screen.dart';
import 'package:smallproject/registrationpage.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'product_listing_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/product_listing': (context) => ProductListingScreen(),
        '/orders': (context) => OrdersScreen(),
        '/registration': (context) => RegistrationPage(),

      },
    );
  }
}
