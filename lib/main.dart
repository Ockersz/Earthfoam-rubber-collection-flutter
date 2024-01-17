import 'package:flutter/material.dart';
import 'package:rubber_collection/tabs_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rubber Collection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
          secondary: Colors.blueAccent,
        ),
        useMaterial3: true,
      ),
      home: const HomeTabs(),
    );
  }
}
