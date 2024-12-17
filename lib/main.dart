import 'package:emergesense/Screens/signin/sign_in_page.dart';
import 'package:emergesense/Screens/signup/signup_page.dart';
import 'package:emergesense/Screens/welcome/welcome_page.dart';
import 'package:emergesense/constant.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Equisense',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   primaryColor: kPrimaryColor,
      //   scaffoldBackgroundColor: Colors.white,
      // ),
      home: WelcomePage(),
      routes: {
        '/signin': (context) => SignInPage(), // Define Sign In page route
        '/signup': (context) => SignupPage(), // Define Sign Up page route
      },
    );
  }
}
