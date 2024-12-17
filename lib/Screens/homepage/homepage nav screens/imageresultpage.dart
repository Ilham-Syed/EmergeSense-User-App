import 'package:flutter/material.dart';
import 'dart:io';

class ImageResultPage extends StatelessWidget {
  final String imagePath;
  final String description;
  final String severity;

  const ImageResultPage({
    required this.imagePath,
    required this.description,
    required this.severity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Function to get color based on severity
    Color getSeverityColor(String severity) {
      switch (severity.toLowerCase()) {
        case 'severe disaster':
          return Colors.red;
        case 'moderate disaster':
          return Colors.orange;
        case 'less severe disaster':
          return Colors.yellow;
        default:
          return Colors.green;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Result'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(
                File(imagePath),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              severity,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: getSeverityColor(severity),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous page
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
