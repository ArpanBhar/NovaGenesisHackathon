import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // goes well with starry background theme
      appBar: AppBar(
        title: const Text("Main Page"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          "🎉 Welcome to the Main Page!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}