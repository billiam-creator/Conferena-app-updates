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
        backgroundColor: CustomColors.lightGreyScaffold,
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
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final isSmall = h < 640;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.08,
          vertical: isSmall ? 12 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // Brand text
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: w / 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
                children: [
                  TextSpan(
                    text: 'CONFE',
                    style: TextStyle(color: CustomColors.textBlack),
                  ),
                  TextSpan(
                    text: 'RENA',
                    style: TextStyle(color: CustomColors.primaryColor),
                  ),
                ],
              ),
            ),

            SizedBox(height: isSmall ? 12 : h * 0.03),

            // QR illustration card
            Container(
              padding: EdgeInsets.all(isSmall ? 14 : 24),
              decoration: BoxDecoration(
                color: CustomColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.asset(
                'assets/images/qr_illustration.png',
                width: isSmall ? w / 2.8 : w / 2.2,
              ),
            ),

            SizedBox(height: isSmall ? 12 : h * 0.03),

            Text(
              'Conferena',
              style: TextStyle(
                color: CustomColors.textBlack,
                fontSize: w / 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isSmall ? 6 : 10),

            Text(
              'Scan the QR code on a ticket to confirm its validity.',
              style: TextStyle(
                color: CustomColors.textGrey,
                fontSize: w / 28,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isSmall ? 20 : h * 0.05),

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
                    MaterialPageRoute(builder: (_) => const TokenEntry()),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(
                  'SCAN WITH TOKEN',
                  style: TextStyle(fontSize: w / 28),
                ),
              ),
            ),

            SizedBox(height: isSmall ? 10 : 16),

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
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.login),
                label: Text(
                  'ORGANIZER LOGIN',
                  style: TextStyle(fontSize: w / 28),
                ),
              ),
            ),

            SizedBox(height: isSmall ? 6 : 14),

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
              icon: Icon(
                Icons.help_outline,
                size: 16,
                color: CustomColors.primaryColor,
              ),
              label: Text(
                'How It Works',
                style: TextStyle(color: CustomColors.primaryColor),
              ),
            ),

          ],
        ),
      ),
    );
  }
}