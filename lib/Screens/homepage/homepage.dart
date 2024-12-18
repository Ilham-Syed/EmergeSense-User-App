import 'package:emergesense/Screens/homepage/homepage%20nav%20screens/imageupload.dart';
import 'package:emergesense/Screens/homepage/homepage%20nav%20screens/reported.disaster.page.dart';
import 'package:emergesense/Screens/homepage/homepage%20nav%20screens/volunteer.register.page.dart';
import 'package:emergesense/constant.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String token; // Ensure the token is of type String
  const HomePage({required this.token, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String name;
  int volunteerCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Decode the token to extract 'name'
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    name = jwtDecodedToken['name']; // Extracting name
    fetchVolunteerCount();
  }

  Future<void> fetchVolunteerCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/volunteer-count'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            volunteerCount = data['count'];
            isLoading = false;
          });
        }
      } else {
        print('Failed to load volunteer count');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Welcome $name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              isLoading
                  ? SizedBox(
                      height: 100, // Fix the height
                      width: 100, // Fix the width
                      child: const CircularProgressIndicator(),
                    )
                  : VolunteerCountIndicator(volunteerCount: volunteerCount),
              const SizedBox(height: 10),
              _buildActionButton(
                color: Colors.blue,
                text:
                    'Encountered a disaster in your locality?\nPost an image of the disaster',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageUpload(token: widget.token),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                color: Colors.green,
                text: 'Register As A Volunteer',
                onTap: () {
                  // Add action here
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const VolunteerRegistrationPage()));
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                color: Colors.red,
                text: 'Disasters Reported',
                onTap: () {
                  // Add action here
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReportedDisasterPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class VolunteerCountIndicator extends StatelessWidget {
  final int volunteerCount;
  const VolunteerCountIndicator({required this.volunteerCount, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Volunteer Registered',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        SizedBox(
          height: 100,
          width: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: volunteerCount / 100, // Assuming 100 is the max value
                backgroundColor: Colors.grey[300],
                color: Colors.green,
                strokeWidth: 12,
              ),
              Text(
                '$volunteerCount',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
