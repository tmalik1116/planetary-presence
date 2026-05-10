import 'package:flutter/material.dart';
import 'widgets/bottom_nav.dart';

void main() {
  runApp(const TrailblazerApp());
}

class TrailblazerApp extends StatelessWidget {
  const TrailblazerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trailblazer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.deepPurpleAccent,
        ),
      ),
      home: const MainShell(),
    );
  }
}
