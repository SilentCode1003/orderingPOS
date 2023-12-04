import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uhordering/api/customerorder.dart';
import 'package:uhordering/api/rating.dart';
import 'package:uhordering/repository/database.dart';

class TrackOrderPage extends StatefulWidget {
  final int customerid;
  final String customername;

  const TrackOrderPage(
      {super.key, required this.customerid, required this.customername});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  List<Order> orders = [];
  List<String> ratings = [];
  String selectedRating = '';

  final TextEditingController _messageController = TextEditingController();

  final DatabaseHelper dh = DatabaseHelper();

  int customerid = 0;

  @override
  void initState() {
    _getcustomerinfo();
    _getrate();
    super.initState();
  }

  Future<void> _getcustomerinfo() async {
    try {
      Database db = await dh.database;

      List<Map<String, dynamic>> customerinfo = await db.query('customer');
      customerinfo.forEach((customer) {
        print(customer);
        setState(() {
          customerid = customer['customerid'];
          _getorderhistory(customerid);
          // contactNumberController.text = customer['contactnumber'];
          // emailController.text = customer['email'];
          // fullname = customer['customername'];
          // gender = customer['gender'];
          // locationregistered = customer['address'];
        });
      });
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

  Future<void> _getorderhistory(customerid) async {
    try {
      final results =
          await CustomerOrderAPI().orderhistory(customerid.toString());
      final jsonData = json.encode(results['data']);

      print(jsonData);

      setState(() {
        for (var data in json.decode(jsonData)) {
          int total = data['total'];
          // print(data['message']);
          orders.add(Order(
            orderid: data['orderid'],
            date: data['date'],
            total: total.toDouble(),
            paymenttype: data['paymenttype'],
            status: data['status'],
            image: '',
            ratestatus: data['message'] ?? 'NORATING',
          ));
        }
      });
      // if (results['msg'] == 'success') {}
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

  void showOrderDetails(BuildContext context, Order order) async {
    try {
      List<Widget> details = [];

      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      final results =
          await CustomerOrderAPI().getorderdetail(order.orderid.toString());
      final jsonData = json.encode(results['data']);

      setState(() {
        for (var data in json.decode(jsonData)) {
          OrderDetails orderdetails = OrderDetails(
            id: data['id'],
            customerid: data['customerid'],
            date: data['date'],
            details: data['details'],
            total: data['total'],
            paymenttype: data['paymenttype'],
            status: data['status'],
          );

          var orderitems = json.decode(orderdetails.details);

          print(orderitems);

          int index = 1;
          for (var items in orderitems) {
            print(items['items']);

            var itemsdetails = json.encode(items['items']);

            for (var item in json.decode(itemsdetails)) {
              print(item);
              int _quantity = item['quantity'];
              double _price = double.parse(item['price']) / _quantity;
              double quantity = _quantity.toDouble();
              double total = _price * quantity;

              details.add(
                ListTile(
                  leading: Text('$index# - $_quantity'),
                  title: Text(item['name']),
                  trailing: Text(
                    '₱${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );

              index++;
            }
          }
        }
      });

      Navigator.of(context).pop();

      showModalBottomSheet(
        constraints: BoxConstraints(
            minWidth: double.infinity, minHeight: double.maxFinite),
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              height: 600, // Set your desired height
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Order ID# ${order.orderid}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${order.date}',
                          style: TextStyle(fontSize: 12, color: Colors.black),
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
                              child: Center(
                                child: Text(
                                  order.status,
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
                          padding: const EdgeInsets.only(top: 5, bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Container(
                              height: 180,
                              color: Colors.grey.shade200,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: details,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 13, bottom: 13),
                          child: Divider(height: 3),
                        ),
                        Row(
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
                                    color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 30),
                            Text(
                              '₱ ${order.total.toStringAsFixed(2)} total',
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
                        Row(
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
                                    color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 30),
                            Text(
                              order.paymenttype,
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
            ),
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
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

  Future<void> _getrate() async {
    try {
      final results = await RateAPI().getRate();
      final jsonData = json.encode(results['data']);

      setState(() {
        for (var data in json.decode(jsonData)) {
          ratings.add(data['description']);
        }
      });
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

  void _feedback(BuildContext context, int orderid) async {
    try {
      showModalBottomSheet(
          constraints: BoxConstraints(
              minWidth: double.infinity, minHeight: double.maxFinite),
          context: context,
          builder: (context) {
            return Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownMenu(
                      inputDecorationTheme:
                          InputDecorationTheme(border: OutlineInputBorder()),
                      leadingIcon: Icon(Icons.star),
                      width: double.maxFinite,
                      initialSelection: ratings.last,
                      onSelected: (String? value) {
                        setState(() {
                          selectedRating = value!;
                        });
                      },
                      dropdownMenuEntries: ratings
                          .map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value, label: value);
                      }).toList(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _messageController,
                      maxLines: 10,
                      decoration: InputDecoration(
                          labelText: 'Please leave a comment',
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String message = _messageController.text;
                        _sendfeedback(
                            context, orderid, selectedRating, message);
                      },
                      child: const Text('Submit'),
                      style: ButtonStyle(
                          minimumSize: MaterialStatePropertyAll(Size(150, 50))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            );
          });
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

  Future<void> _sendfeedback(
      BuildContext context, int orderid, String rating, String message) async {
    try {
      final results =
          await RateAPI().feedback(orderid.toString(), rating, message);
      final jsonData = json.encode(results['data']);

      if (results['msg'] == 'success') {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text('Success'),
                content: Text('Thank you for your feedback!'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/trackorder');
                      },
                      child: const Text('OK'))
                ],
              );
            });
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
            if (orders.isEmpty)
              const Text(
                'No Orders',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  Order order = orders[index];
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
                                          'assets/logo.jpg',
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
                                              'Order #:${order.orderid}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                            ),
                                          ),
                                          const SizedBox(width: 30),
                                          Text(
                                            'Price: \₱${order.total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          order.status,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          order.date,
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
                                      showOrderDetails(context, order);
                                    },
                                    child: const Text('Detailed View'),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                if (orders[index].ratestatus == 'NORATING' &&
                                    orders[index].status == 'COMPLETED')
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // showOrderDetails(context, order);
                                        _feedback(context, order.orderid);
                                      },
                                      child: const Text('Feedback'),
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

class Order {
  final int orderid;
  final String date;
  final double total;
  final String paymenttype;
  final String status;
  final String image;
  final String ratestatus;

  Order({
    required this.image,
    required this.orderid,
    required this.date,
    required this.total,
    required this.paymenttype,
    required this.status,
    required this.ratestatus,
  });
}

class OrderDetails {
  final int id;
  final int customerid;
  final String date;
  final String details;
  final int total;
  final String paymenttype;
  final String status;

  OrderDetails({
    required this.id,
    required this.customerid,
    required this.date,
    required this.details,
    required this.total,
    required this.paymenttype,
    required this.status,
  });
}
