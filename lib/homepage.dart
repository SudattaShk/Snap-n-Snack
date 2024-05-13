import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String? _fruitName;
  double? _calories;
  String? _imageBase64;

  Future<void> _getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _predictFruitCalories() async {
    print('Sending request to API...');

    if (_image == null) {
      print('No image selected');
      return;
    }

    final url = 'http://192.168.101.19:8000/predict/';
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    print('Sending request...');
    final response = await request.send();

    if (response.statusCode == 200) {
      print('Request successful');
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      setState(() {
        _fruitName = data['name'];
        _calories = data['calories'].toDouble();
        _imageBase64 = data['image_base64'];
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snap n Snack'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
              ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _getImageFromCamera,
                  child: Text('Camera'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _getImageFromGallery,
                  child: Text('Gallery'),
                ),
              ],
            ),
            SizedBox(height: 5),
            if (_image != null)
              ElevatedButton(
                onPressed: _predictFruitCalories,
                child: Text('OK'),
              ),
            SizedBox(height: 5),
            if (_fruitName != null && _calories != null)
              Column(
                children: [
                  Text('Fruit: $_fruitName'),
                  Text('Calories: $_calories'),
                  SizedBox(height:1),
                  if (_imageBase64 != null)
                    Image.memory(
                      base64Decode(_imageBase64!),
                      height: 380,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
