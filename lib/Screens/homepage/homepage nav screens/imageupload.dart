import 'dart:convert';
import 'dart:io';
import 'package:emergesense/Screens/homepage/homepage%20nav%20screens/imageresultpage.dart';
import 'package:emergesense/constant.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:http/http.dart' as http;

class ImageUpload extends StatefulWidget {
  final String token; // Add token parameter

  const ImageUpload({required this.token, super.key});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  File? _image;
  String? _location;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // Pick an image or take a photo
  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });
      await _extractLocation(imageFile);
    }
  }

  // Extract location metadata
  Future<void> _extractLocation(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final data = await readExifFromBytes(bytes);

      if (data.containsKey('GPS GPSLatitude') &&
          data.containsKey('GPS GPSLongitude')) {
        final lat = _convertToDegrees(data['GPS GPSLatitude']!.values.toList());
        final lon =
            _convertToDegrees(data['GPS GPSLongitude']!.values.toList());
        setState(() {
          _location = 'Lat: $lat, Lon: $lon';
        });
      } else {
        setState(() {
          _location = 'Location not available in metadata';
        });
      }
    } catch (e) {
      setState(() {
        _location = 'Error extracting location';
      });
    }
  }

  // Helper to convert EXIF GPS data to degrees
  double _convertToDegrees(List<dynamic> values) {
    return values[0].toDouble() +
        values[1].toDouble() / 60 +
        values[2].toDouble() / 3600;
  }

  // Send data to backend
  Future<void> _submitData() async {
    if (_image != null && _location != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Backend API endpoint
        const String apiUrl = '$baseUrl/upload-image';

        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

        request.files
            .add(await http.MultipartFile.fromPath('image', _image!.path));
        request.fields['location'] = jsonEncode(_location);

        // Add the user token to the request headers
        request.headers['Authorization'] = 'Bearer ${widget.token}';

        var response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await http.Response.fromStream(response);
          var message = jsonDecode(responseData.body);

          if (message['success']) {
            String description = message['description'];
            String severity = message['severity'];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageResultPage(
                  imagePath: _image!.path,
                  description: description,
                  severity: severity,
                ),
              ),
            );
          } else {
            print("Error: ${message['message']}");
          }
        } else {
          print('Error uploading data: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Image or location data missing');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content:
              const Text('Please provide an image with valid location data'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Disaster Image'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _image != null
                      ? Image.file(
                          _image!,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        )
                      : const Text('No image selected'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _getImage(ImageSource.camera),
                    child: const Text('Take Photo'),
                  ),
                  ElevatedButton(
                    onPressed: () => _getImage(ImageSource.gallery),
                    child: const Text('Pick from Gallery'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _location ?? 'Location metadata will be displayed here',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitData,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
    );
  }
}
