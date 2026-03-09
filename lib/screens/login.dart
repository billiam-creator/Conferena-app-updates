import 'package:flutter/material.dart';
import '../widgets/my_button.dart';
import '../widgets/my_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() {

    String email = emailController.text;
    String password = passwordController.text;

    print("Email: $email");
    print("Password: $password");

    // API call will go here later
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[300],

      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 40),

              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 30),

              Text(
                "Sign in",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Welcome back to Conferena",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              MyTextfield(
                controller: emailController,
                hintText: 'Enter your email',
                obscureText: false,
              ),

              const SizedBox(height: 15),

              MyTextfield(
                controller: passwordController,
                hintText: 'Enter your password',
                obscureText: true,
              ),

              const SizedBox(height: 25),

              MyButton(
                onTap: signUserIn,
              ),

            ],
          ),
        ),
      ),
    );
  }
}