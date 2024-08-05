import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api.dart';

/// The `HomePage` widget is the main screen of the Snap n Snack application.
/// It allows users to take or choose a picture, predict the fruit in the image,
/// and display the name of the fruit along with its estimated calories.

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// The selected image file.
  File? _image;

  /// The name of the predicted fruit.
  String? _fruitName;

  /// The estimated calories of the predicted fruit
  double? _calories;

  /// The base64 representation of the selected image.
  String? _imageBase64;

  /// Retrieves an image from the device's camera.
  Future<void> _getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// Retrieves an image from the device's gallery.
  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// Shows an error dialog when there's an issue predicting the fruit.
  void _showPredictionErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Prediction Error'),
          content: Text(errorMessage),
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

  /// Sends a request to the API to predict the fruit and its calories in the selected image.
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
      String errorMessage = 'The image is too big or too small';



      _showPredictionErrorDialog(errorMessage);
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
            SizedBox(height: 2),
            if (_image != null)
              ElevatedButton(
                onPressed: _predictFruitCalories,
                child: Text('OK'),
              ),
            SizedBox(height: 2),
            if (_fruitName != null && _calories != null)
              Column(
                children: [
                  Text(
                    'Fruit: $_fruitName',
                    style: TextStyle(fontSize: 24), // Increase font size
                  ),
                  Text(
                    'Calories: $_calories',
                    style: TextStyle(fontSize: 24), // Increase font size
                  ),
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
