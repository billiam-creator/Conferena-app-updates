import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../widgets/my_button.dart';
import '../widgets/my_textfield.dart';
import 'package:ticketkona/screens/events_list.dart';
import 'package:ticketkona/services/session_manager.dart';
import 'package:ticketkona/config.dart';
import 'package:ticketkona/theme/colors.dart';

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

  String? emailError;
  String? passwordError;
  String? generalError;

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

  void _shake() => _shakeController.forward(from: 0);

  String? _extractSessionCookie(http.Response response) {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie == null) return null;
    final match = RegExp(r'ci_session=([^;]+)').firstMatch(rawCookie);
    return match?.group(1);
  }

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

  void _openForgotPassword() {
    const forgotPasswordUrl = '${AppConfig.baseUrl}/users/register/forgot_pass';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("To reset your password, visit:"),
            const SizedBox(height: 8),
            SelectableText(
              forgotPasswordUrl,
              style: const TextStyle(
                color: Color(0xFF01875f),
                decoration: TextDecoration.underline,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Copy the link and open it in your browser to reset your password.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void signUserIn() async {
    if (!_validate()) { _shake(); return; }

    _clearErrors();
    setState(() => isLoading = true);

    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final response = await http.post(
        Uri.parse(AppConfig.apiLogin),
        body: {'identity': email, 'password': password},
      ).timeout(const Duration(seconds: 15));

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
          } catch (e) { print("Web login attempt failed: $e"); }
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
        final serverMsg = (data['message'] ?? '').toString().toLowerCase();
        setState(() {
          if (serverMsg.contains('password')) {
            passwordError = "Incorrect password. Please try again.";
          } else if (serverMsg.contains('email') || serverMsg.contains('user') ||
                     serverMsg.contains('not found') || serverMsg.contains('identity')) {
            emailError = "No account found with this email.";
          } else if (serverMsg.contains('invalid') || serverMsg.contains('wrong')) {
            passwordError = "Incorrect email or password.";
          } else {
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
    } on http.ClientException {
      setState(() {
        generalError = "Unable to reach the server. Please check your connection.";
        isLoading = false;
      });
      _shake();
    } on Exception catch (e) {
      setState(() {
        generalError = "Something went wrong. Please try again.";
        isLoading = false;
      });
      print("LOGIN EXCEPTION: $e");
      _shake();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.grey[800];
    final textSecondary = isDark ? Colors.white60 : Colors.grey[700];

    return Scaffold(
      // ✅ Uses theme scaffold color — works in both light and dark
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
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

                  // ✅ White background so logo is visible in dark mode
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  Text(
                    "Sign in",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: MediaQuery.of(context).size.height < 600 ? 22 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Welcome back to Conferena",
                    style: TextStyle(color: textSecondary, fontSize: 14),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),

                  // General error banner
                  if (generalError != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.red.shade900.withOpacity(0.4) : Colors.red.shade50,
                        border: Border.all(
                            color: isDark ? Colors.red.shade700 : Colors.red.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              generalError!,
                              style: TextStyle(
                                  color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (generalError != null) const SizedBox(height: 16),

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
                                Icon(Icons.info_outline,
                                    size: 13, color: Colors.red.shade400),
                                const SizedBox(width: 4),
                                Text(emailError!,
                                    style: TextStyle(
                                        color: Colors.red.shade400, fontSize: 12)),
                              ],
                            ),
                          ),

                        const SizedBox(height: 14),

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
                                Icon(Icons.info_outline,
                                    size: 13, color: Colors.red.shade400),
                                const SizedBox(width: 4),
                                Text(passwordError!,
                                    style: TextStyle(
                                        color: Colors.red.shade400, fontSize: 12)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: savePassword,
                              activeColor: CustomColors.primaryColor,
                              onChanged: (val) =>
                                  setState(() => savePassword = val ?? false),
                            ),
                            Text("Remember me",
                                style: TextStyle(color: textPrimary)),
                          ],
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(left: 12)),
                          onPressed: _openForgotPassword,
                          child: const Text("Forgot Password?",
                              style: TextStyle(
                                  color: CustomColors.primaryColor)),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  isLoading
                      ? const CircularProgressIndicator(
                          color: CustomColors.primaryColor)
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

Widget _buildLogo(BuildContext context, {double height = 90}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Image.asset(
    isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo_light.png',
    height: height,
  );
}