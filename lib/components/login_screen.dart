import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                    Navigator.pushReplacementNamed(context, '/dashboard');
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
