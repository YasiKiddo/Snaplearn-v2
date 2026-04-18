import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(SnapLearnApp());
}

class SnapLearnApp extends StatelessWidget {
  const SnapLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapLearn ',
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Poppins'),
      home: HomeScreen(),
    );
  }
}
