import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:uhordering/api/customercredit.dart';
import 'package:uhordering/components/activeorder.dart';
import 'package:uhordering/components/product_listing_screen.dart';
import 'package:uhordering/components/trackorder.dart';
import 'package:uhordering/repository/database.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:url_launcher/url_launcher.dart';

class Slide {
  Slide({
    required this.title,
    required this.height,
    required this.imagePath,
  });

  final String imagePath;
  final double height;
  final String title;
}

const double uniformSlideHeight = 250.0;

var slideImagePaths = [
  'ricemeals.jpg',
  'drinkricemeals.jpg',
  'drinksricemeals2.jpg'
];

var slides = List.generate(
  slideImagePaths.length,
  (index) => Slide(
    title: 'Slide ${index + 1}',
    height: uniformSlideHeight,
    imagePath: 'assets/${slideImagePaths[index]}',
  ),
);

final List<Widget> sliders = slides
    .map(
      (item) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          child: SizedBox(
            width: double.infinity,
            height: item.height,
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
      ),
    )
    .toList();

// void main() => runApp(const Dashoboard());

// class Dashoboard extends StatelessWidget {
//   final int customerid;
//   const Dashoboard({super.key, required this.customerid});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Your App Title',
//       home: DashboardScreen(),
//     );
//   }
// }

class DashboardScreen extends StatefulWidget {
  final String customername;
  final int customerid;
  DashboardScreen(
      {super.key, required this.customername, required this.customerid});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper dh = DatabaseHelper();
  String customername = '';
  int customerid = 0;
  double credit = 0;

  @override
  void initState() {
    _getcredit();
    super.initState();
  }

  Future<void> _openFacebookApp() async {
    const facebookAppUrl = "fb://UrbanHideoutCafe?mibextid=ZbWKwL"; // Facebook app custom URL scheme

    if (await canLaunch(facebookAppUrl)) {
      await launch(facebookAppUrl);
    } else {
      // Handle error, for example, show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Could not open Facebook app.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _getcredit() async {
    try {
      Database db = await dh.database;
      List<Map<String, dynamic>> customerinfo = await db.query('customer');

      for (var customer in customerinfo) {
        setState(() {
          customername = '${customer['customername']}';
          customerid = customer['customerid'];
        });
      }
      final results =
          await CustomerCreditAPI().getcredit(customerid.toString());
      final jsonData = json.encode(results['data']);

      print('customerid: ${customerid}');

      if (results['msg'] != 'success') {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Faild'),
                content: const Text('Faild to fetch credit data!'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'))
                ],
              );
            });
      } else {
        int balance = 0;
        for (var data in json.decode(jsonData)) {
          balance = data['balance'];
          print('balance: $balance');

          setState(() {
            credit = balance.toDouble();
          });
        }
      }
    } catch (e) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('$e'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    // _getcredit(args);
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false, // This line hides the back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Urban Hideout Cafe'),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [Text('\₱ ${credit.toStringAsFixed(2)}')],
            )
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                      child: Image.asset(
                    'assets/logo.jpg',
                    fit: BoxFit.fill,
                    height: 80,
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Urban Hideout Cafe',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        customername,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      Text(
                        '\₱ ${credit.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_2_rounded),
              title: const Text('Profile'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Orders'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveOrderPage(
                      customerid: customerid,
                      customername: customername,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackOrderPage(
                      customerid: customerid,
                      customername: customername,
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 120,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.facebook),
              title: const Text('Facebook'),
              onTap: () {
                // Add your action when Settings is tapped
                // Navigator.pushReplacementNamed(context, '/login');
                _openFacebookApp();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          // Product Recommendations Section
          const SizedBox(
            height: 5,
          ),
          ExpandableCarousel(
            options: CarouselOptions(
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 10),
              disableCenter: false,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              slideIndicator: const CircularSlideIndicator(),
            ),
            items: sliders,
          ),

          // Dashboard Buttons Section
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                children: <Widget>[
                  DashboardItem(
                    title: 'Menu',
                    icon: Icons.shopping_cart,
                    onTap: () {
                      // Navigator.pushNamed(context, '/product_listing');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListingScreen(
                            customerid: customerid,
                            credit: credit,
                          ),
                        ),
                      );
                    },
                  ),
                  DashboardItem(
                    title: 'Orders',
                    icon: Icons.assignment,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackOrderPage(
                            customerid: customerid,
                            customername: customername,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTap;

  const DashboardItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 64),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
