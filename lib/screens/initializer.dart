import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ticketkona/screens/home.dart';
import 'package:ticketkona/screens/events_list.dart';
import 'package:ticketkona/screens/onboarding_screen.dart';
import 'package:ticketkona/services/session_manager.dart';
import 'package:ticketkona/services/settings_manager.dart';
import 'package:ticketkona/theme/colors.dart';
import 'package:ticketkona/config.dart';

class Initializer extends StatefulWidget {
  const Initializer({Key? key}) : super(key: key);

  @override
  State<Initializer> createState() => _InitializerState();
}

class _InitializerState extends State<Initializer>
    with SingleTickerProviderStateMixin {

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1000), _checkSession);
      }
    });
  }

  Future<void> _checkSession() async {
    // ── Check onboarding first ─────────────────────────────────────────────
    final hasSeenOnboarding = await SettingsManager.hasSeenOnboarding();
    if (!hasSeenOnboarding) {
      await _animController.reverse();
      if (!mounted) return;
      // Show onboarding; it will call markOnboardingSeen then go to Home
      Navigator.pushReplacement(
        context,
        _fadeRoute(const OnboardingScreen(fromHome: false)),
      );
      return;
    }

    // ── Check saved session ────────────────────────────────────────────────
    final session = await SessionManager.loadSession();
    if (!mounted) return;

    if (session != null) {
      print("ACTIVE SESSION FOUND — refreshing token");
      final creds = await SessionManager.loadCredentials();

      if (creds != null &&
          creds['email'] != null &&
          creds['password'] != null) {
        print("RE-LOGGING IN WITH SAVED CREDENTIALS");
        try {
          final response = await http.post(
            Uri.parse(AppConfig.apiLogin),
            body: {
              'identity': creds['email']!,
              'password': creds['password']!,
            },
          ).timeout(const Duration(seconds: 10));

          final data = jsonDecode(response.body);

          if (response.statusCode == 200 && data['status'] == 200) {
            final newToken = data['access_token'] ?? data['token'] ?? '';
            print("TOKEN REFRESHED: $newToken");

            String? newCookie;
            final rawCookie = response.headers['set-cookie'];
            if (rawCookie != null) {
              final match = RegExp(r'ci_session=([^;]+)').firstMatch(rawCookie);
              newCookie = match?.group(1);
            }

            if (newCookie == null) {
              try {
                final webRes = await http.post(
                  Uri.parse(AppConfig.webLogin),
                  headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                  },
                  body: {
                    'identity': creds['email']!,
                    'password': creds['password']!,
                  },
                ).timeout(const Duration(seconds: 10));
                final wRaw = webRes.headers['set-cookie'];
                if (wRaw != null) {
                  final m =
                      RegExp(r'ci_session=([^;]+)').firstMatch(wRaw);
                  newCookie = m?.group(1);
                }
              } catch (_) {}
            }

            await SessionManager.saveSession(
              token: newToken,
              sessionCookie: newCookie,
            );

            if (!mounted) return;
            await _animController.reverse();
            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              _fadeRoute(EventsList(
                token: newToken,
                sessionCookie: newCookie,
              )),
            );
            return;
          }
        } catch (e) {
          print("AUTO RE-LOGIN FAILED: $e — using saved token");
        }
      }

      // Fallback: use saved token
      await _animController.reverse();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        _fadeRoute(EventsList(
          token: session['token'] ?? '',
          sessionCookie: session['sessionCookie'],
        )),
      );
    } else {
      print("NO SESSION — going to Home");
      await _animController.reverse();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        _fadeRoute(const Home()),
      );
    }
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.initializerScaffold,
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (_, __) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: MediaQuery.of(context).size.width / 1.3,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}