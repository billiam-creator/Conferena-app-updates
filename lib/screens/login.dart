import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/my_button.dart';
import '../widgets/my_textfield.dart';
import 'package:ticketkona/screens/events_list.dart';
import 'package:ticketkona/config.dart';
import 'package:ticketkona/services/session_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading    = false;
  bool savePassword = false; // "Remember me" toggle

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Pre-fill email/password if user previously chose "Remember me"
  Future<void> _loadSavedCredentials() async {
    final creds = await SessionManager.loadCredentials();
    if (creds != null) {
      setState(() {
        emailController.text    = creds['email']    ?? '';
        passwordController.text = creds['password'] ?? '';
        savePassword = true;
      });
    }
  }

  String? _extractSessionCookie(http.Response response) {
    final rawCookie = response.headers['set-cookie'];
    print("RAW SET-COOKIE HEADER: $rawCookie");
    if (rawCookie == null) return null;
    final match = RegExp(r'ci_session=([^;]+)').firstMatch(rawCookie);
    if (match != null) {
      print("EXTRACTED ci_session: ${match.group(1)}");
      return match.group(1);
    }
    return null;
  }

  void signUserIn() async {

    String email    = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {

      final response = await http.post(
        Uri.parse(AppConfig.apiLogin),
        body: {
          'identity': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 10));

      print("LOGIN STATUS: ${response.statusCode}");
      var data = jsonDecode(response.body);
      print("LOGIN RESPONSE KEYS: ${data.keys.toList()}");

      if (response.statusCode == 200 && data["status"] == 200) {

        String token = data['access_token'] ?? data['token'] ?? '';
        String? sessionCookie = _extractSessionCookie(response);

        // If no cookie from API login, try the web login endpoint
        if (sessionCookie == null) {
          print("Trying web login for session cookie...");
          try {
            final webResponse = await http.post(
              Uri.parse(AppConfig.webLogin),
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              body: {'identity': email, 'password': password},
            ).timeout(const Duration(seconds: 10));

            print("WEB LOGIN STATUS: ${webResponse.statusCode}");
            sessionCookie = _extractSessionCookie(webResponse);
            print("SESSION COOKIE FROM WEB LOGIN: $sessionCookie");
          } catch (e) {
            print("Web login attempt failed: $e");
          }
        }

        // Save session 
        await SessionManager.saveSession(
          token: token,
          sessionCookie: sessionCookie,
        );

        // Save or clear credentials 
        if (savePassword) {
          await SessionManager.saveCredentials(
            email: email,
            password: password,
          );
        } else {
          await SessionManager.clearCredentials();
        }

        if (!mounted) return;

       
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EventsList(
              token: token,
              sessionCookie: sessionCookie,
            ),
          ),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Login failed. Please try again."),
          ),
        );
      }

    } on http.ClientException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to reach server. Please try again later.")),
      );
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected server response.")),
      );
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error. Check your internet connection.")),
      );
    }

    setState(() => isLoading = false);
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Image.asset('assets/images/logo.png', height: 100),

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
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),

                const SizedBox(height: 25),

                // Email field — autofillHints enables Google autofill
                AutofillGroup(
                  child: Column(
                    children: [
                      MyTextfield(
                        controller: emailController,
                        hintText: 'Enter your email',
                        obscureText: false,
                        autofillHints: const [AutofillHints.email],
                      ),

                      const SizedBox(height: 15),

                      MyTextfield(
                        controller: passwordController,
                        hintText: 'Enter your password',
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Remember me toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Checkbox(
                        value: savePassword,
                        activeColor: const Color(0xFFF82249),
                        onChanged: (val) {
                          setState(() => savePassword = val ?? false);
                        },
                      ),
                      const Text("Remember me"),
                    ],
                  ),
                ),

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
                    : MyButton(onTap: signUserIn),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}