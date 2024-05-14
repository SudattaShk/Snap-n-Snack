import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> predictFruit(File imageFile) async {
  final url = 'http://192.168.101.19:8000/predict/';
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
