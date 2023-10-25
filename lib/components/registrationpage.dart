import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smallproject/api/customer.dart';

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

  // Define a regular expression to match only letters
  final RegExp letterRegExp = RegExp(r'^[A-Za-z]+$');

  Future<void> _registercustomer() async {
    String firstname = firstNameController.text;
    String middlename = middleNameController.text;
    String lastname = lastNameController.text;
    String contact = contactNumberController.text;
    String address = addressController.text;
    String username = usernameController.text;
    String password = passwordController.text;
    final results = await CustomerAPI().registerCustomer(firstname, middlename,
        lastname, contact, gender.toString(), address, username, password);

    if (results['msg'] == 'success') {
      _backtologin();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 280.0,
              maxWidth: 450.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: TextField(
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
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: TextField(
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
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: TextField(
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
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: TextField(
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
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: Row(
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
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: TextField(
                    controller: addressController,
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
                      labelText: 'Address',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      border: OutlineInputBorder(),
                      hintText: 'Enter Address',
                      prefixIcon: Icon(Icons.home),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: TextField(
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
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: TextField(
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
                ),
                const SizedBox(height: 20),
                Container(
                    constraints: const BoxConstraints(
                      minWidth: 200.0,
                      maxWidth: 380.0,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _registercustomer();
                      },
                      icon: const Icon(Icons.app_registration_rounded),
                      label: const Text('Register'),
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(
                            Size(double.maxFinite, 50)),
                        maximumSize: MaterialStateProperty.all<Size>(
                            Size(double.maxFinite, 50)),
                      ),
                    )),
                const SizedBox(height: 10),
                Container(
                    constraints: const BoxConstraints(
                      minWidth: 200.0,
                      maxWidth: 380.0,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(
                            Size(double.maxFinite, 50)),
                        maximumSize: MaterialStateProperty.all<Size>(
                            Size(double.maxFinite, 50)),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
