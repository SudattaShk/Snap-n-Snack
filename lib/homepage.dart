import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api.dart';

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

    try {
      final data = await predictFruit(_image!);
      print('API response received:');
      print(data);
      setState(() {
        _fruitName = data['name'];
        _calories = data['calories'].toDouble();
        _imageBase64 = data['image_base64'];
      });
    } catch (e) {
      print('Error predicting fruit: $e');

      // Check if the error is due to image size
      if (e.toString().contains('The image is too big') ||
          e.toString().contains('The image is too small')) {
        // Show pop-up if image size is not suitable for prediction
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Prediction Error'),
              content: Text('The image size is not suitable for prediction.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Show generic error pop-up
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Selected image too big or too small.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
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
                  SizedBox(height: 1),
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
