import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp (const MyApp() );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
            final url = Uri.parse('http://127.0.0.1:8000/health');
            http.get(url).then((response) {
              if (response.statusCode == 200) {
                print('Server is healthy: ${response.body}');
              }
            }).catchError((error) {
              print('Error connecting to server: $error');
            });
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ), //scaffolds provide a structure to the app
        appBar: AppBar(
          title: const Text('Clubbies'),
          backgroundColor: Colors.lightBlue,
        ),
        backgroundColor: Colors.purple,
        body: Center(
          child: Container(
            height: 300,
            width: 300,
            color: Colors.white,
            child: const Icon(
              Icons.favorite,
              color: Colors.pink,
              size: 50.0,
            ),
          ),
        ),
      ),
    );
  }
}

