import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../widgets/my_button.dart';
import '../widgets/my_textfield.dart';
import 'package:ticketkona/screens/events_list.dart';
import 'package:ticketkona/services/session_manager.dart';
import 'package:ticketkona/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading    = false;
  bool savePassword = false;

  // Inline error messages shown under each field
  String? emailError;
  String? passwordError;
  String? generalError;

  // Shake animation for wrong credentials
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

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

  void _clearErrors() {
    setState(() {
      emailError   = null;
      passwordError = null;
      generalError  = null;
    });
  }

  // Shake the form to signal wrong credentials
  void _shake() {
    _shakeController.forward(from: 0);
  }

  String? _extractSessionCookie(http.Response response) {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie == null) return null;
    final match = RegExp(r'ci_session=([^;]+)').firstMatch(rawCookie);
    return match?.group(1);
  }

  // Client-side validation before hitting the server
  bool _validate() {
    bool valid = true;
    setState(() {
      emailError    = null;
      passwordError = null;
      generalError  = null;
    });

    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => emailError = "Email address is required");
      valid = false;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => emailError = "Enter a valid email address");
      valid = false;
    }

    if (password.isEmpty) {
      setState(() => passwordError = "Password is required");
      valid = false;
    } else if (password.length < 4) {
      setState(() => passwordError = "Password is too short");
      valid = false;
    }

    return valid;
  }

  void signUserIn() async {
    if (!_validate()) {
      _shake();
      return;
    }

    _clearErrors();
    setState(() => isLoading = true);

    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    try {

      final response = await http.post(
        Uri.parse(AppConfig.apiLogin),
        body: {'identity': email, 'password': password},
      ).timeout(const Duration(seconds: 15));

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      // Handle non-JSON response (e.g. server down / returning HTML)
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        setState(() {
          generalError = "Server returned an unexpected response. Please try again.";
          isLoading = false;
        });
        _shake();
        return;
      }

      if (response.statusCode == 200 && data["status"] == 200) {

        String token = data['access_token'] ?? data['token'] ?? '';
        String? sessionCookie = _extractSessionCookie(response);

        if (sessionCookie == null) {
          try {
            final webResponse = await http.post(
              Uri.parse(AppConfig.webLogin),
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              body: {'identity': email, 'password': password},
            ).timeout(const Duration(seconds: 10));
            sessionCookie = _extractSessionCookie(webResponse);
          } catch (e) {
            print("Web login attempt failed: $e");
          }
        }

        await SessionManager.saveSession(token: token, sessionCookie: sessionCookie);

        if (savePassword) {
          await SessionManager.saveCredentials(email: email, password: password);
        } else {
          await SessionManager.clearCredentials();
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EventsList(token: token, sessionCookie: sessionCookie),
          ),
        );

      } else {

        // Map server error messages to friendly field-level errors
        final serverMsg = (data['message'] ?? '').toString().toLowerCase();
        setState(() {
          if (serverMsg.contains('password')) {
            passwordError = "Incorrect password. Please try again.";
          } else if (serverMsg.contains('email') ||
                     serverMsg.contains('user') ||
                     serverMsg.contains('account') ||
                     serverMsg.contains('not found') ||
                     serverMsg.contains('identity')) {
            emailError = "No account found with this email.";
          } else if (serverMsg.contains('credential') ||
                     serverMsg.contains('invalid') ||
                     serverMsg.contains('wrong')) {
            passwordError = "Incorrect email or password.";
          } else {
            // Fallback — show server message or generic
            generalError = data['message'] ?? "Login failed. Please check your credentials.";
          }
          isLoading = false;
        });
        _shake();
        return;
      }

    } on TimeoutException {
      setState(() {
        generalError = "Request timed out. Check your internet connection and try again.";
        isLoading = false;
      });
      _shake();
      return;
    } on http.ClientException {
      setState(() {
        generalError = "Unable to reach the server. Please check your connection.";
        isLoading = false;
      });
      _shake();
      return;
    } on Exception catch (e) {
      setState(() {
        generalError = "Something went wrong. Please try again.";
        isLoading = false;
      });
      print("LOGIN EXCEPTION: $e");
      _shake();
      return;
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                // Horizontal shake offset
                final offset = _shakeController.isAnimating
                    ? 8 * (0.5 - (_shakeAnimation.value % 0.5)) * 4
                    : 0.0;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
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

                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                  Image.asset(
                    'assets/images/logo.png',
                    height: MediaQuery.of(context).size.height * 0.12,
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  Text(
                    "Sign in",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: MediaQuery.of(context).size.height < 600 ? 22 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Welcome back to Conferena",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),

                  // ── General error banner ─────────────────────────
                  if (generalError != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              generalError!,
                              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (generalError != null) const SizedBox(height: 16),

                  // ── Email field ──────────────────────────────────
                  AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        MyTextfield(
                          controller: emailController,
                          hintText: 'Enter your email',
                          obscureText: false,
                          autofillHints: const [AutofillHints.email],
                          hasError: emailError != null,
                          onChanged: (_) => setState(() => emailError = null),
                        ),

                        if (emailError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 28, top: 5),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 13, color: Colors.red.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  emailError!,
                                  style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 14),

                        // ── Password field ───────────────────────────
                        MyTextfield(
                          controller: passwordController,
                          hintText: 'Enter your password',
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          hasError: passwordError != null,
                          onChanged: (_) => setState(() => passwordError = null),
                        ),

                        if (passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 28, top: 5),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 13, color: Colors.red.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  passwordError!,
                                  style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Remember me & Forgot Password ───────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: savePassword,
                              activeColor: const Color(0xFFF82249),
                              onChanged: (val) => setState(() => savePassword = val ?? false),
                            ),
                            const Text("Remember me"),
                          ],
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(left: 12),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please contact admin to reset password.")),
                            );
                          },
                          child: const Text("Forgot Password?"),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  isLoading
                      ? const CircularProgressIndicator()
                      : MyButton(onTap: signUserIn),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}