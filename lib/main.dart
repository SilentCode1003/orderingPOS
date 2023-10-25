import 'package:flutter/material.dart';
import 'package:smallproject/components/orders_screen.dart';
import 'package:smallproject/components/registrationpage.dart';
import 'components/login_screen.dart';
import 'components/dashboard_screen.dart';
import 'components/product_listing_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       theme: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown)),
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
