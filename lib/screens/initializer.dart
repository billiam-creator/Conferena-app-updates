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

class _InitializerState extends State<Initializer>
    with SingleTickerProviderStateMixin {

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // Animation: logo fades + scales in over 800ms
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

    // Start animation immediately — no white screen wait
    _animController.forward();

    // Check session after animation completes + a short hold
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Hold the logo for 1 second after it finishes animating in
        Future.delayed(const Duration(milliseconds: 1000), _checkSession);
      }
    });
  }

  Future<void> _checkSession() async {
    final session = await SessionManager.loadSession();
    if (!mounted) return;

    // Fade out before navigating
    await _animController.reverse();
    if (!mounted) return;

    if (session != null) {
      Navigator.pushReplacement(
        context,
        _fadeRoute(EventsList(
          token: session['token'] ?? '',
          sessionCookie: session['sessionCookie'],
        )),
      );
    } else {
      Navigator.pushReplacement(
        context,
        _fadeRoute(const Home()),
      );
    }
  }

  // Smooth fade transition instead of the default slide
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