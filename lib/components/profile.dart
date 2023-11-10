import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uhordering/api/customer.dart';
import 'package:uhordering/components/dashboard_screen.dart';
import 'package:uhordering/repository/database.dart';
import 'package:uhordering/repository/geolocator.dart';
import 'package:geodesy/geodesy.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String gender = '';

  ZoomLevel zoomLevel = ZoomLevel(17.5);
  MapController mapController = MapController();
  String _locationname = '';

  double _latitude = 0;
  double _longitude = 0;
  LatLng activelocation = LatLng(0, 0);
  LatLng manuallySelectedLocation = LatLng(0, 0);

  int customerid = 0;
  String fullname = '';
  String locationregistered = '';

  final StreamController<LatLng> _streamController = StreamController<LatLng>();

  final DatabaseHelper dh = DatabaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    getCurrentLocation().then((Position position) {
      // Use the position data
      double latitude = position.latitude;
      double longitude = position.longitude;

      setState(() {
        _latitude = latitude;
        _longitude = longitude;
        activelocation = LatLng(latitude, longitude);
        manuallySelectedLocation = LatLng(latitude, longitude);
      });

      _centerMapToDefaultLocation(activelocation);

      getGeolocationName(latitude, longitude)
          .then((locationname) => {
                setState(() {
                  _locationname = locationname;
                })
              })
          .catchError((onError) => print(onError));
    });

    _getcustomerinfo();

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
          contactNumberController.text = customer['contactnumber'];
          emailController.text = customer['email'];
          fullname = customer['customername'];
          gender = customer['gender'];
          locationregistered = customer['address'];
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
          manuallySelectedLocation = LatLng(latitude, longitude);
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

  void _selectLocation(LatLng location) {
    setState(() {
      manuallySelectedLocation = location;
      _streamController.add(location);
      getGeolocationName(location.latitude, location.longitude)
          .then((locationname) => {
                setState(() {
                  _locationname = locationname;
                })
              })
          .catchError((onError) => print(onError));
    });
  }

  Future<void> _getcurrentaddress() async {
    try {
      await _getCurrentLocation();
      LatLng activelocation = LatLng(_latitude, _longitude);
      // String address = _locationname;

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Scaffold(
              body: StreamBuilder<LatLng>(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
                    return AlertDialog(
                      title: Text('Verify Location'),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 400,
                        child: Expanded(
                          child: FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              center: activelocation,
                              zoom: zoomLevel.level,
                              onTap: (point, latlng) {
                                _selectLocation(latlng);

                                // Check if the selected location is inside circledomain, circledomaintwo, or thirdcircle
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 80.0,
                                    height: 80.0,
                                    point: manuallySelectedLocation,
                                    child: Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 40.0,
                                    ),
                                  ),
                                  // Marker(
                                  //     point: activelocation,
                                  //     child: const Icon(
                                  //       Icons.location_pin,
                                  //       color: Colors.red,
                                  //       size: 40.0,
                                  //     ))
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
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              dispose();
                              Navigator.pushReplacementNamed(
                                  context, '/profile');
                            },
                            child: const Text('Confirm')),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/profile');
                            },
                            child: const Text('Close'))
                      ],
                    );
                  }),
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

  void _centerMapToDefaultLocation(lanlang) {
    mapController.move(lanlang, zoomLevel.level);
    setState(() {
      activelocation = lanlang;
    });
  }

  Future<void> _update(contact, email, address) async {
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      final results = await CustomerAPI()
          .updatecustomer(contact, email, address, customerid.toString());
      // final jsonData = json.encode(results['data']);

      Navigator.of(context).pop();

      if (results['msg'] == 'success') {
        Map<String, dynamic> customer = {
          "customerid": customerid,
          "customername": fullname,
          "contactnumber": contact,
          "gender": gender,
          "address": address,
          "email": email,
        };
        dh.updateItem(customer, 'customer', 'customerid=?', customerid);

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: Text('Updated info successfully submitted!'),
                actions: [
                  TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/profile'),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown)),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            height: double.maxFinite,
            padding: EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: contactNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]')),
                    ],
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      labelText: 'Contact Number',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      border: OutlineInputBorder(),
                      hintText: 'Enter Contact Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      labelText: 'Email',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      border: OutlineInputBorder(),
                      hintText: 'Enter Email Number',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Container(
                  //   height: 60,
                  //   child: ElevatedButton(
                  //       onPressed: () {
                  //         _getcurrentaddress();
                  //       },
                  //       child: const Text('UPDATE ADDRESS')),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 260,
                    child: StreamBuilder<Object>(
                        stream: _streamController.stream,
                        builder: (context, snapshot) {
                          return FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              center: activelocation,
                              zoom: zoomLevel.level,
                              onTap: (point, latlng) {
                                _selectLocation(latlng);
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 80.0,
                                    height: 80.0,
                                    point: manuallySelectedLocation,
                                    child: Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 40.0,
                                    ),
                                  ),
                                  // Marker(
                                  //     point: activelocation,
                                  //     child: const Icon(
                                  //       Icons.location_pin,
                                  //       color: Colors.red,
                                  //       size: 40.0,
                                  //     ))
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
                          );
                        }),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Current Address: $_locationname',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Registered Address: $locationregistered',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  )
                ]),
          ),
        ),
        bottomNavigationBar: Container(
          height: 80,
          child: BottomAppBar(
            child: ElevatedButton(
                onPressed: () {
                  String contact = contactNumberController.text;
                  String email = emailController.text;
                  String address = _locationname;

                  print('test');

                  _update(contact, email, address);
                },
                child: const Text('UPDATE')),
          ),
        ),
      ),
    );
  }
}

class ZoomLevel {
  double level;

  ZoomLevel(this.level);
}
