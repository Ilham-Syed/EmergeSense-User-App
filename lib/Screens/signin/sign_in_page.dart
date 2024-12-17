import 'dart:convert';

import 'package:emergesense/Screens/homepage/homepage.dart';
import 'package:emergesense/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isNotValidated = false;
  late SharedPreferences prefers;
  late Future<void> _initPrefsFuture;

  @override
  void initState() {
    super.initState();
    _initPrefsFuture = initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    prefers = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    await _initPrefsFuture;
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      var loginBody = {
        'email': _usernameController.text,
        'password': _passwordController.text,
      };
      var response = await http.post(
        Uri.parse("$baseUrl/login"), //make constant ip
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginBody),
      );

      var message = jsonDecode(response.body);

      if (message['success']) {
        var tokendata = message['token'];
        prefers.setString('token', tokendata);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(token: tokendata),
          ),
        );
      } else {
        print("Login failed");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In Page'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Set the form key
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              // Username Field
              TextFormField(
                controller: _usernameController,
                style:
                    TextStyle(color: Colors.white), // Set text color to white
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  labelStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Icon(Icons.person, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true, // Hide password input
                style:
                    TextStyle(color: Colors.white), // Set text color to white
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  labelStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Sign In Button
              ElevatedButton(
                onPressed: () {
                  loginUser();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
