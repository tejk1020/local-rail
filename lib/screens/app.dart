import 'package:flutter/material.dart';
import 'splash_screen.dart';

class SmartLocalTrainApp extends StatelessWidget {
  const SmartLocalTrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Local Train',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        fontFamily: 'Arial',
      ),
      home: const SplashScreen(),
    );
  }
}