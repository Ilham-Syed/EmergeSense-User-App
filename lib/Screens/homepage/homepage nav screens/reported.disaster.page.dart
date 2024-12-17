import 'dart:convert';
import 'package:emergesense/constant.dart'; // Ensure constants are defined here, e.g., baseUrl
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportedDisasterPage extends StatefulWidget {
  const ReportedDisasterPage({super.key});

  @override
  State<ReportedDisasterPage> createState() => _ReportedDisasterPageState();
}

class _ReportedDisasterPageState extends State<ReportedDisasterPage> {
  List<dynamic> _disasterData = [];

  @override
  void initState() {
    super.initState();
    _fetchDisasterData();
  }

  Future<void> _fetchDisasterData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/image-locations'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _disasterData = data['data'];
          });
        }
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported Disaster'),
        backgroundColor: Colors.blue,
      ),
      body: _disasterData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _disasterData.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final disaster = _disasterData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 10.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location: ${disaster['location']}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            const Text(
                              'Severity: ',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              disaster['severity'],
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: _getSeverityColor(disaster['severity']),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Helper function to determine the color based on severity level
  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe disaster':
        return Colors.red;
      case 'Moderate disaster':
        return Colors.orange;
      case 'less severe disaster':
        return Colors.yellow[700]!;
      default:
        return Colors.green;
    }
  }
}
