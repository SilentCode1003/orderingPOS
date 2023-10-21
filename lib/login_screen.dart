import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(height: 100, child: Image.asset('assets/testimage.png')),
            const SizedBox(height: 20),
            const Text('Welcome to the Online Ordering System'),
            Container(
              constraints: const BoxConstraints(
                minWidth: 280.0,
                maxWidth: 450.0,
              ),
              child: const TextField(
                decoration: InputDecoration(labelText: 'Username'),
              ),
            ),
            Container(
              constraints: const BoxConstraints(
                minWidth: 280.0,
                maxWidth: 450.0,
              ),
              child: const TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 40),
            TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/registration');
                },
                child: const Text('Not Registered yet?  Click here!'))
          ],
        ),
      ),
    );
  }
}
