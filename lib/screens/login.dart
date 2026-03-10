import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/my_button.dart';
import '../widgets/my_textfield.dart';
import 'package:ticketkona/screens/events_list.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void signUserIn() async {

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http
          .post(
            Uri.parse('https://bemmas.brainversetechnologies.co.ke/api/login'),
            body: {
              'identity': email,
              'password': password,
            },
          )
          .timeout(const Duration(seconds: 10));

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == 200) {

        String token = data['access_token'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventsList(token: token),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? "Login failed. Please try again.",
            ),
          ),
        );

      }

    } on http.ClientException {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to reach server. Please try again later."),
        ),
      );

    } on FormatException {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unexpected server response."),
        ),
      );

    } on Exception {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Network error. Check your internet connection."),
        ),
      );

    }

    setState(() {
      isLoading = false;
    });

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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  
  children: [
    
    IconButton(
      
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
      
    ),
  ],
),

                const SizedBox(height: 40),

                Image.asset(
  'assets/images/logo.png',
  height: 100,
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
                const SizedBox(height: 10,),
                TextButton(
  onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please contact admin to reset password."),
      ),
    );
  },
  child: const Text("Forgot Password?"),
),

                const SizedBox(height: 25),

                isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(
                        onTap: signUserIn,
                      ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}