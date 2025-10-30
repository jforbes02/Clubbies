import 'package:flutter/material.dart';
import 'pages/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clubbies',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        useMaterial3: true,
      ),
      home: AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
    
  }
}