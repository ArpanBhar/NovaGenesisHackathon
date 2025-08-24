import 'package:celestia/signup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'starry_background.dart'; // <-- put the StarryBackground + StarPainter code in this file

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
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
                  onPressed: () {},
                  child: const Text("Log In"),
                ),
                const SizedBox(height: 15),
                RichText(
                  text: TextSpan(
                    text: "Don’t have an account? ",
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SignUpPage(),
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
