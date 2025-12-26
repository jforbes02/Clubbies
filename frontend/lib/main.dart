import 'package:flutter/material.dart';
import 'pages/auth.dart';
import 'services/auth_service.dart';

// Global navigator key for context-independent navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Initialize auth service with navigator key
  AuthService.initialize(navigatorKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Add global navigator key
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