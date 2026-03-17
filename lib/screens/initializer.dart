import 'package:flutter/material.dart';
import 'package:ticketkona/screens/home.dart';
import 'package:ticketkona/screens/events_list.dart';
import 'package:ticketkona/services/session_manager.dart';
import 'package:ticketkona/theme/colors.dart';

class Initializer extends StatefulWidget {
  const Initializer({Key? key}) : super(key: key);

  @override
  State<Initializer> createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Show splash for at least 2 seconds while checking session
    await Future.delayed(const Duration(milliseconds: 2000));

    final session = await SessionManager.loadSession();

    if (!mounted) return;

    if (session != null) {
      print("ACTIVE SESSION FOUND — skipping login");
      // Session exists and is not expired — go straight to events
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EventsList(
            token: session['token'] ?? '',
            sessionCookie: session['sessionCookie'],
          ),
        ),
      );
    } else {
      print("NO SESSION — going to Home");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.initializerScaffold,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery.of(context).size.width / 1.3,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}