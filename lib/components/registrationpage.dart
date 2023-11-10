import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uhordering/api/customer.dart';
import 'package:uhordering/repository/geolocator.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  String? gender;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Define a regular expression to match only letters
  final RegExp letterRegExp = RegExp(r'^[A-Za-z]+$');

  MapController mapController = MapController();
  ZoomLevel zoomLevel = ZoomLevel(17.5);

  double _latitude = 0;
  double _longitude = 0;
  String _locationname = '';
  LatLng manuallySelectedLocation = LatLng(0, 0);
  LatLng activelocation = LatLng(0, 0);

  final StreamController<LatLng> _streamController = StreamController<LatLng>();

  @override
  void initState() {
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

    super.initState();
  }

  void _centerMapToDefaultLocation(lanlang) {
    mapController.move(lanlang, zoomLevel.level);
    setState(() {
      activelocation = lanlang;
    });
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

  Future<void> _registercustomer() async {
    try {
      String firstname = firstNameController.text;
      String middlename = middleNameController.text;
      String lastname = lastNameController.text;
      String contact = contactNumberController.text;
      String email = emailController.text;
      String username = usernameController.text;
      String password = passwordController.text;
      String message = '';

      if (firstname == '') {
        message += 'First Name ';
      }

      if (middlename == '') {
        message += 'Middle Name ';
      }

      if (lastname == '') {
        message += 'Last Name ';
      }

      if (contact == '') {
        message += 'Contact ';
      }
      if (email == '') {
        message += 'Email ';
      }

      if (username == '') {
        message += 'Username ';
      }

      if (password == '') {
        message += 'Password ';
      }
      if (gender.toString() == '') {
        message += 'Gender ';
      }

      if (message != '') {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Warning'),
                content: Text('Required fields $message'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'))
                ],
              );
            });
      } else {
        await _getCurrentLocation();

        String address = _locationname;

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return StreamBuilder<Object>(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
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
                              _selectLocation(activelocation);

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
                                    point: manuallySelectedLocation,
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
                              _register(
                                  firstname,
                                  middlename,
                                  lastname,
                                  contact,
                                  email,
                                  gender,
                                  address,
                                  username,
                                  password);
                            },
                            child: const Text('Confirm')),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/registration');
                            },
                            child: const Text('Close'))
                      ],
                    );
                  });
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

  Future<void> _register(firstname, middlename, lastname, contact, email,
      gender, address, username, password) async {
    try {
      final results = await CustomerAPI().registerCustomer(
          firstname,
          middlename,
          lastname,
          contact,
          email,
          gender.toString(),
          _locationname,
          username,
          password);

      if (results['msg'] == 'success') {
        _backtologin();
      }
      if (results['msg'] == 'exist') {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Warning'),
                content: const Text('You have already an account!'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
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

  // Function to display a dialog box
  // Function to display a dialog box that is not dismissible by tapping outside
  void _backtologin() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Success!')),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Registered Successfully!'),
              Text('You will be redirected back to login.'),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('OK'),
                ),
              ),
            ),
          ],
        );
      },
    );
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

      await getCurrentLocation().then((Position position) async {
        // Use the position data
        double latitude = position.latitude;
        double longitude = position.longitude;

        setState(() {
          _latitude = latitude;
          _longitude = longitude;
        });

        await getGeolocationName(latitude, longitude)
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown)),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Registration'),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: firstNameController,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                    ],
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      labelText: 'First Name',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      border: OutlineInputBorder(),
                      hintText: 'Enter First Name',
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  TextField(
                    controller: middleNameController,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                    ],
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      labelText: 'Middle Name',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      border: OutlineInputBorder(),
                      hintText: 'Enter Middle Name',
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  TextField(
                    controller: lastNameController,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                    ],
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      labelText: 'Last Name',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      border: OutlineInputBorder(),
                      hintText: 'Enter Last Name',
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  TextField(
                    controller: contactNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[a-z]')),
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
                      hintText: 'Enter Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      const Text('Gender: '),
                      Radio<String>(
                        value: 'Male',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                      const Text('Male'),
                      Radio<String>(
                        value: 'Female',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                      const Text('Female'),
                      Radio<String>(
                        value: 'Other',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                      const Text('Other'),
                    ],
                  ),
                  // TextField(
                  //   controller: addressController,
                  //   keyboardType: TextInputType.text,
                  //   decoration: const InputDecoration(
                  //     filled: true,
                  //     fillColor: Colors.white,
                  //     focusedBorder: OutlineInputBorder(
                  //       borderSide:
                  //           BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  //     ),
                  //     labelText: 'Address',
                  //     labelStyle:
                  //         TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  //     border: OutlineInputBorder(),
                  //     hintText: 'Enter Address',
                  //     prefixIcon: Icon(Icons.home),
                  //   ),
                  // ),
                  TextField(
                    controller: usernameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      labelText: 'Username',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      border: OutlineInputBorder(),
                      hintText: 'Username',
                      prefixIcon: Icon(Icons.perm_identity),
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      labelText: 'Password',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      border: OutlineInputBorder(),
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.password),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 80,
          child: BottomAppBar(
              child: ElevatedButton.icon(
            onPressed: () {
              _registercustomer();
            },
            icon: const Icon(Icons.app_registration_rounded),
            label: const Text('Register'),
            style: ButtonStyle(
              minimumSize:
                  MaterialStateProperty.all<Size>(Size(double.maxFinite, 50)),
              maximumSize:
                  MaterialStateProperty.all<Size>(Size(double.maxFinite, 50)),
            ),
          )),
        ),
      ),
    );
  }
}

class ZoomLevel {
  double level;

  ZoomLevel(this.level);
}
