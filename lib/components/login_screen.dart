import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smallproject/api/customer.dart';
import 'package:smallproject/components/dashboard_screen.dart';
import 'package:smallproject/repository/database.dart';
import 'package:sqflite_common/sqlite_api.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper dh = DatabaseHelper();
  String customername = '';
  int customerid = 0;

  Future<void> _login() async {
    final BuildContext capturedContext = context;
    try {
      String username = _usernameController.text;
      String password = _passwordController.text;
      final results = await CustomerAPI().customerLogin(username, password);
      final jsonData = json.encode(results['data']);

      Database db = await dh.database;

      List<Map<String, dynamic>> customerinfo = await db.query('customer');

      if (username == "" && password == "") {
        return showDialog(
            context: capturedContext,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Empty Fields'),
                content: const Text('Username and Password is empty'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(capturedContext),
                      child: const Text('OK'))
                ],
              );
            });
      }

      if (results['msg'] == 'success') {
        if (jsonData.length == 2) {
          showDialog(
              context: capturedContext,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Warning'),
                  content: const Text('Username and Password not match!'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'))
                  ],
                );
              });
        } else {
          if (customerinfo.isNotEmpty) {
            for (var customer in customerinfo) {
              // String name = pos['posid'];
              print('${customer}');
              dh.updateItem(
                  customer, 'customer', 'customerid=?', customer['storeid']);
              // Process data

              setState(() {
                customername = '${customer['customername']}';
                customerid = customer['customerid'];
              });
            }
          } else {
            if (jsonData.length != 2) {
              for (var data in json.decode(jsonData)) {
                await dh.insertItem({
                  "customerid": data['id'],
                  "customername":
                      '${data['firstname']} ${data['middlename']} ${data['lastname']}',
                  "contactnumber": data['contactnumber'],
                  "gender": data['gender'],
                  "address": data['address'],
                }, 'customer');

                setState(() {
                  customerid = data['id'];
                  customername =
                      '${data['firstname']} ${data['middlename']} ${data['lastname']}';
                });
              }

              List<Map<String, dynamic>> customerinfo =
                  await db.query('customer');
              for (var customer in customerinfo) {
                print(
                    '${customer['customerid']} ${customer['customername']} ${customer['contactnumber']} ${customer['gender']} ${customer['address']}');
              }
            } else {}
          }

          showDialog(
              context: capturedContext,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Login Success'),
                  content: const Text('Login Successfull'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          // Navigator.pushReplacementNamed(context, '/dashboard',
                          //     arguments: {
                          //       'customername': customername,
                          //       'customerid': customerid
                          //     });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DashboardScreen(
                                        customerid: customerid,
                                        customername: customername,
                                      )));

                          // Navigator.pushReplacementNamed(context, '/dashboard');
                        },
                        child: const Text('OK'))
                  ],
                );
              });
        }
      } else {
        showDialog(
            context: capturedContext,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('${results['msg']}'),
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
          context: capturedContext,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                height: 200,
                width: 200,
                child: ClipOval(
                    child: Image.asset(
                  'assets/logo.jpg',
                  fit: BoxFit.fill,
                ))),
            const SizedBox(height: 20),
            const Text('Welcome to the Online Ordering System'),
            const SizedBox(height: 5),
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 380.0,
              ),
              child: TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'Enter Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 380.0,
              ),
              child: TextField(
                controller: _passwordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'Enter Password',
                  prefixIcon: Icon(Icons.password),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
                constraints: const BoxConstraints(
                  minWidth: 200.0,
                  maxWidth: 380.0,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigator.pushReplacementNamed(context, '/dashboard');
                    _login();
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(double.maxFinite, 50)),
                    maximumSize: MaterialStateProperty.all<Size>(
                        Size(double.maxFinite, 50)),
                  ),
                )),
            const SizedBox(height: 40),
            TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/registration');
                },
                child: const Text(
                  'Not Registered yet?  Click here!',
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
