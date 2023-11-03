import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smallproject/components/activeorder.dart';
import 'package:smallproject/components/registrationpage.dart';
import 'package:smallproject/components/trackorder.dart';
import 'package:smallproject/repository/database.dart';
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
          'CREATE TABLE customer (customerid int, customername varchar(300), contactnumber varchar(13), gender varchar(7), address text)');
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
      },
    );
  }
}
