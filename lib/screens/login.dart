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

 void signUserIn() async {

  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  if(email.isEmpty || password.isEmpty){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter email and password"))
    );
    return;
  }

  try {

    final response = await http.post(
      Uri.parse('https://maji.brainversetechnologies.co.ke/api/login'),
      body: {
        'identity': email,
        'password': password,
      },
    );

    var data = jsonDecode(response.body);

    if(response.statusCode == 200){

      String token = data['access_token'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventsList(token: token),
        ),
      );

    }else{

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "Login failed"))
      );

    }

  } catch(e){

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e"))
    );

  }

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