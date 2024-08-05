import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// A function to send an image file to an API endpoint for fruit prediction.
///
/// It takes an [imageFile] of type File as input, which represents the image
/// to be sent for prediction. The function sends a POST request to the specified
/// API endpoint with the image file as a multipart form data. Upon receiving
/// a successful response from the API, it parses the JSON data and returns
/// a Map<String, dynamic> containing the predicted fruit information.
///
/// If the request fails or an error occurs during the process, it throws an
/// Exception with an appropriate error message.
Future<Map<String, dynamic>> predictFruit(File imageFile) async {
  final url = 'http://10.10.9.207:8000/predict/';
  final request = http.MultipartRequest('POST', Uri.parse(url));
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    return jsonDecode(responseData);
  } else {
    throw Exception('Failed to predict fruit.');
  }
}
