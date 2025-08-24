import 'package:celestia/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'starry_background.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  final emailEditingController = TextEditingController();
  final passEditingController = TextEditingController();
  void createUser() async{
    final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailEditingController.text.trim(), 
      password: passEditingController.text.trim()
    );
    print(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarryBackground(
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailEditingController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passEditingController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {createUser();},
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 15),
                RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Log In",
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
