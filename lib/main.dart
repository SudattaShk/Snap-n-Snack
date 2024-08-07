// main.dart
import 'package:flutter/material.dart';
import 'homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Calorie Estimation',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
       colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
       )
    ),
    );
  }
}