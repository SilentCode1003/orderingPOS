import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:uhordering/api/customerorder.dart';
import 'package:uhordering/api/payments.dart';
import 'package:uhordering/components/product_listing_screen.dart';
import 'package:uhordering/repository/geolocator.dart';
import 'package:geodesy/geodesy.dart';

class OrderScreen extends StatefulWidget {
  final Map<String, int> cart;
  final Function(String) deductToCart;
  final Function(String) addToCart;
  final Function(String) removeToCart;
  int totalCartItems;
  Map<String, double> totalPrices;
  final List<Product> productlist;
  final int customerid;
  final double credit;
  OrderScreen(
      {super.key,
      required this.cart,
      required this.deductToCart,
      required this.addToCart,
      required this.removeToCart,
      required this.customerid,
      required this.credit,
      required this.totalCartItems,
      required this.totalPrices,
      required this.productlist});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String paymenttype = '';
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> order = [];
  double _latitude = 0;
  double _longitude = 0;
  String _locationname = '';
  String currentLocation = '';
  double total = 0.0;

  final TextEditingController _transactionReferenceNumberController =
      TextEditingController();

  MapController mapController = MapController();
  ZoomLevel zoomLevel = ZoomLevel(17.5);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getCurrentLocation() async {
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      await getCurrentLocation().then((Position position) {
        // Use the position data
        double latitude = position.latitude;
        double longitude = position.longitude;

        setState(() {
          _latitude = latitude;
          _longitude = longitude;
        });

        getGeolocationName(latitude, longitude)
            .then((locationname) => {
                  setState(() {
                    _locationname = locationname;
                  })
                })
            .catchError((onError) => print(onError));
      });

      Navigator.of(context).pop();
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

  Future<void> _sendorder() async {
    try {
      if (paymenttype == "UH POINTS") {
        order.add({
          'items': items,
          'address': _locationname,
          'latitude': _latitude,
          'longitude': _longitude,
          'points': total
        });
      } else {
        if (paymenttype != 'COD') {
          String reference = _transactionReferenceNumberController.text;
          order.add({
            'items': items,
            'address': _locationname,
            'latitude': _latitude,
            'longitude': _longitude,
            'reference': reference
          });
        } else {
          order.add({
            'items': items,
            'address': _locationname,
            'latitude': _latitude,
            'longitude': _longitude
          });
        }
      }

      final results = await CustomerOrderAPI().order(
          widget.customerid.toString(),
          json.encode(order),
          total.toString(),
          paymenttype);
      // final jsonData = json.encode(results['data']);

      if (results['msg'] != 'success') {
      } else {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: Text('Order successfully placed'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/dashboard');
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

  Future<void> _order() async {
    try {
      await _getCurrentLocation();
      LatLng activelocation = LatLng(_latitude, _longitude);
      for (int index = 0; index < widget.cart.length; index++) {
        String product = widget.cart.keys.elementAt(index);
        int? quantity = widget.cart[product];
        Product? productData = widget.productlist.firstWhere(
          (p) => p.name == product,
          orElse: () => Product("Product Not Found", 0.0, ""),
        );

        double totalPrice = productData.price * quantity!;

        items.add({
          'name': product,
          'price': totalPrice.toStringAsFixed(2),
          'quantity': quantity
        });
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Verify Location'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: activelocation,
                    zoom: zoomLevel.level,
                    onTap: (point, activelocation) {
                      // _selectLocation(latLng);

                      // Check if the selected location is inside circledomain, circledomaintwo, or thirdcircle
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      // subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                            point: activelocation,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40.0,
                            ))
                        // Marker(
                        //   width: 80.0,
                        //   height: 80.0,
                        //   point: activelocation,
                        //   builder: (context) => const Icon(
                        //     Icons.location_pin,
                        //     color: Colors.red,
                        //     size: 40.0,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _sendorder();
                    },
                    child: const Text('Confirm')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'))
              ],
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

  Future<void> _payment() async {
    try {
      List<String> paymentlist = [];
      final results = await PaymentAPI().getPayment();
      final jsonData = json.encode(results['data']);

      setState(() {
        for (var data in json.decode(jsonData)) {
          paymentlist.add(data['name']);
        }
      });

      final List<Widget> payment = List<Widget>.generate(
          paymentlist.length,
          (index) => ElevatedButton(
              onPressed: () {
                setState(() {
                  paymenttype = paymentlist[index];
                });

                Navigator.of(context).pop();
                if (paymenttype == "UH POINTS") {
                  if (widget.credit < total) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Insufficient'),
                            content: Text(
                                'You have insufficient $paymenttype, you have only ${widget.credit.toStringAsFixed(2)} but you total purchase is ${total.toStringAsFixed(2)}'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'))
                            ],
                          );
                        });
                  } else {
                    _order();
                  }
                } else {
                  if (paymenttype != 'COD') {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Input Transaction Reference"),
                            content: Container(
                              height: 80,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 200.0,
                                      maxWidth: 380.0,
                                    ),
                                    child: TextField(
                                      controller:
                                          _transactionReferenceNumberController,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                        labelText: 'Referecnce No.',
                                        labelStyle: TextStyle(
                                            color:
                                                Color.fromARGB(255, 0, 0, 0)),
                                        border: OutlineInputBorder(),
                                        hintText: 'Enter Referecnce No.',
                                        prefixIcon: Icon(Icons.receipt_long),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    String reference =
                                        _transactionReferenceNumberController
                                            .text;
                                    if (reference == '') {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Empty'),
                                              content: const Text(
                                                  'Please provide your transaction reference no for verification'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('OK'))
                                              ],
                                            );
                                          });
                                    } else {
                                      Navigator.of(context).pop();
                                      _order();
                                    }
                                  },
                                  child: const Text('OK'))
                            ],
                          );
                        });
                  } else {
                    _order();
                  }
                }
              },
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                maximumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
              ),
              child: Text(
                paymentlist[index],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )));

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Select Payment Method'),
              content: Container(
                height: double.maxFinite,
                width: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      runAlignment: WrapAlignment.spaceEvenly,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: payment,
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
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

  @override
  Widget build(BuildContext context) {
    List<Widget> cartItems = [];
    double totalitems = 0.0;

    for (int index = 0; index < widget.cart.length; index++) {
      setState(() {
        String product = widget.cart.keys.elementAt(index);
        var quantity = widget.cart[product];
        Product productData = widget.productlist.firstWhere(
          (p) => p.name == product,
          orElse: () => Product("Product Not Found", 0.0, ""),
        );

        if (productData != null) {
          double totalPrice = productData.price * quantity!;
          totalitems += totalPrice;
          cartItems.add(Card(
            elevation: 3,
            margin: const EdgeInsets.all(5),
            child: ListTile(
              title: Text('$product - $quantity'),
              subtitle: Text('Total Price:\₱${totalPrice.toStringAsFixed(2)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 5),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          widget.addToCart(product);
                        });
                      },
                      icon: Icon(Icons.plus_one)),
                  const SizedBox(width: 5),
                  IconButton(
                      onPressed: () {
                        widget.deductToCart(product);
                        setState(() {});
                      },
                      icon: Icon(Icons.exposure_minus_1)),
                  const SizedBox(width: 5),
                  IconButton(
                      onPressed: () {
                        widget.removeToCart(product);
                        setState(() {});
                      },
                      icon: Icon(
                          Icons.delete)) // Add some spacing between the buttons
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
      });
    }

    total = totalitems;

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
            subtitle: Text('Total Price: \₱ ${total.toStringAsFixed(2)}'),
            trailing: Container(
                constraints: const BoxConstraints(
                  minWidth: 200.0,
                  maxWidth: 380.0,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _payment();
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

class ZoomLevel {
  double level;

  ZoomLevel(this.level);
}
