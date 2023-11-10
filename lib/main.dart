import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uhordering/components/activeorder.dart';
import 'package:uhordering/components/notification.dart';
import 'package:uhordering/components/orders_screen.dart';
import 'package:uhordering/components/profile.dart';
import 'package:uhordering/components/registrationpage.dart';
import 'package:uhordering/components/trackorder.dart';
import 'package:uhordering/repository/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'components/login_screen.dart';
import 'components/dashboard_screen.dart';
import 'components/product_listing_screen.dart';

void main() {
  if (Platform.isAndroid) {
    DatabaseHelper dh = DatabaseHelper();
    dh.database;
  } else if (Platform.isWindows) {
    // Initialize the sqflite FFI bindings
    sqfliteFfiInit();

    // Set the databaseFactory to use the FFI version
    databaseFactory = databaseFactoryFfi;

    // Now you can use the database APIs
    openDatabase('customerinfo.db', version: 1, onCreate: (db, version) {
      // Create your database schema here
      db.execute(
          'CREATE TABLE customer (customerid int, customername varchar(300), contactnumber varchar(13), gender varchar(7), address text, email varchar(300))');
      print('done creating customer table');
    }).then((db) {
      // Database is now open and ready to use
    }).catchError((error) {
      // Handle any errors during database initialization
      print('Error opening database: $error');
    });
  }
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
        '/dashboard': (context) => DashboardScreen(
              customername: '',
              customerid: 0,
            ),
        '/product_listing': (context) => const ProductListingScreen(
              customerid: 0,
              credit: 0,
            ),
        '/registration': (context) => RegistrationPage(),
        '/trackorder': (context) => const TrackOrderPage(
              customerid: 0,
              customername: '',
            ),
        '/activeorder': (context) => const ActiveOrderPage(
              customerid: 0,
              customername: '',
            ),
        '/orderscreen': (context) => OrderScreen(
              customerid: 0,
              cart: {},
              deductToCart: (String) {},
              addToCart: (String) {},
              removeToCart: (String) {},
              credit: 0,
              totalCartItems: 0,
              totalPrices: {},
              productlist: [],
            ),
        '/profile': (context) => const ProfilePage(),
        '/notification': (context) =>  NotificationPage(),
      },
    );
  }
}
