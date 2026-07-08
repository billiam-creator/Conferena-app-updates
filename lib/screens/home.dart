import 'package:flutter/material.dart';
import 'package:ticketkona/screens/token_entry.dart';
import 'package:ticketkona/screens/login.dart';
import 'package:ticketkona/screens/support_page.dart';
import 'package:ticketkona/screens/settings_page.dart';
import 'package:ticketkona/screens/onboarding_screen.dart';
import 'package:ticketkona/theme/colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedTab = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    SupportPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        // No hardcoded backgroundColor here — Scaffold falls back to
        // Theme.of(context).scaffoldBackgroundColor automatically, which
        // switches correctly between AppTheme.light() and AppTheme.dark().
        body: SafeArea(child: _pages[_selectedTab]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          selectedItemColor: CustomColors.primaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _selectedTab = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.support_agent_outlined),
              activeIcon: Icon(Icons.support_agent),
              label: 'Support',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : CustomColors.textBlack;
    final subtitleColor = isDark ? Colors.grey[400]! : CustomColors.textGrey;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Cap the max width on tablets/large screens so the layout still
        // matches the phone-sized design instead of stretching everything.
        final maxContentWidth =
            constraints.maxWidth > 480 ? 480.0 : constraints.maxWidth;
        final isSmall = constraints.maxHeight < 640;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: SizedBox(
                width: maxContentWidth,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: isSmall ? 16 : 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      // Brand text
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arial',
                          ),
                          children: [
                            TextSpan(
                              text: 'CONFE',
                              style: TextStyle(color: titleColor),
                            ),
                            TextSpan(
                              text: 'RENA',
                              style: const TextStyle(
                                  color: CustomColors.primaryColor),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmall ? 20 : 32),

                      // QR illustration card
                      Container(
                        padding: EdgeInsets.all(isSmall ? 20 : 28),
                        decoration: BoxDecoration(
                          color: CustomColors.primaryColor
                              .withOpacity(isDark ? 0.16 : 0.08),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Image.asset(
                          'assets/images/qr_illustration.png',
                          width: isSmall ? 120 : 160,
                        ),
                      ),

                      SizedBox(height: isSmall ? 20 : 32),

                      Text(
                        'Conferena',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: isSmall ? 20 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Scan the QR code on a ticket to confirm its validity.',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isSmall ? 28 : 40),

                      // Scan with token button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: isSmall ? 12 : 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TokenEntry()),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text(
                            'SCAN WITH TOKEN',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),

                      SizedBox(height: isSmall ? 12 : 16),

                      // Organizer Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: isSmall ? 12 : 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                            );
                          },
                          icon: const Icon(Icons.login),
                          label: const Text(
                            'ORGANIZER LOGIN',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),

                      SizedBox(height: isSmall ? 8 : 14),

                      // How It Works link
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const OnboardingScreen(fromHome: true),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.help_outline,
                          size: 16,
                          color: CustomColors.primaryColor,
                        ),
                        label: const Text(
                          'How It Works',
                          style:
                              TextStyle(color: CustomColors.primaryColor),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}