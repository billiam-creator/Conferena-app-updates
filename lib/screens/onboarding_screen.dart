import 'package:flutter/material.dart';
import 'package:ticketkona/theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  // fromHome=true means it was opened via "How It Works" (not first launch)
  // so it shows a close/back button instead of being part of the launch flow
  final bool fromHome;

  const OnboardingScreen({super.key, this.fromHome = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardSlide> _slides = const [
    _OnboardSlide(
      title: 'Organiser access',
      subtitle: 'Sign in to manage your events and check guests in.',
      steps: [
        _Step(number: 1, icon: Icons.login, title: 'Log in', desc: 'Use your organiser email and password.'),
        _Step(number: 2, icon: Icons.event_note, title: 'Access your events', desc: 'See every event assigned to you.'),
        _Step(number: 3, icon: Icons.qr_code_scanner, title: 'Scan to check in', desc: 'Open an event and start validating tickets.'),
      ],
    ),
    _OnboardSlide(
      title: 'Scan to check in',
      subtitle: 'Validate any ticket in three quick steps.',
      steps: [
        _Step(number: 1, icon: Icons.vpn_key_outlined, title: 'Enter event code', desc: 'Type the scanning token for your event.'),
        _Step(number: 2, icon: Icons.qr_code_scanner, title: 'Tap scan', desc: 'Point the camera at the ticket QR code.'),
        _Step(number: 3, icon: Icons.check_circle_outline, title: 'See the result', desc: 'Instant valid, used, or invalid feedback.'),
      ],
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _skip() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: _skip,
                  child: const Text('Skip', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) => _SlideView(slide: _slides[index]),
              ),
            ),

            // Dots + buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? CustomColors.primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _controller.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _next,
                          icon: Icon(_currentPage == _slides.length - 1
                              ? Icons.check
                              : Icons.arrow_forward),
                          label: Text(
                            _currentPage == _slides.length - 1
                                ? 'Get started'
                                : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _OnboardSlide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            slide.title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            slide.subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 28),
          ...slide.steps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: CustomColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${s.number}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            Text(s.desc,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _OnboardSlide {
  final String title;
  final String subtitle;
  final List<_Step> steps;
  const _OnboardSlide({required this.title, required this.subtitle, required this.steps});
}

class _Step {
  final int number;
  final IconData icon;
  final String title;
  final String desc;
  const _Step({required this.number, required this.icon, required this.title, required this.desc});
}
