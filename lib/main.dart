import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naija Food Finder UK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MyHomePage(title: 'Naija Food Finder UK 🇳🇬🇬🇧'),
    );
  }
}
