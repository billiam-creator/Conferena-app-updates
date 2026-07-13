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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: SafeArea(child: _pages[_selectedTab]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          selectedItemColor: CustomColors.primaryColor,
          unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final isSmall = h < 640;

    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black45;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.08,
          vertical: isSmall ? 16 : 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ── CONFERENA brand text ──────────────────────────────
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: w / 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'CONFE',
                    style: TextStyle(color: textPrimary),
                  ),
                  const TextSpan(
                    text: 'RENA',
                    style: TextStyle(color: CustomColors.primaryColor),
                  ),
                ],
              ),
            ),

            SizedBox(height: isSmall ? 20 : h * 0.04),

            // ── QR icon card (matches design) ─────────────────────
            Container(
              width: w * 0.42,
              height: w * 0.42,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A3D2E)
                    : CustomColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/qr_illustration.png',
                  width: w * 0.28,
                ),
              ),
            ),

            SizedBox(height: isSmall ? 20 : h * 0.04),

            // ── Title ─────────────────────────────────────────────
            Text(
              'Conferena',
              style: TextStyle(
                color: textPrimary,
                fontSize: w / 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // ── Subtitle ──────────────────────────────────────────
            Text(
              'Scan the QR code on a ticket to confirm its validity.',
              style: TextStyle(
                color: textSecondary,
                fontSize: w / 26,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isSmall ? 28 : h * 0.055),

            // ── Organizer Login (primary action — matches design) ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isSmall ? 13 : 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                icon: const Icon(Icons.login, size: 18),
                label: Text(
                  'Organizer Login',
                  style: TextStyle(
                    fontSize: w / 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Scan with token (secondary action) ────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: CustomColors.primaryColor,
                  side: const BorderSide(
                      color: CustomColors.primaryColor, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: isSmall ? 13 : 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TokenEntry()),
                ),
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: Text(
                  'Scan with Token',
                  style: TextStyle(
                    fontSize: w / 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── How It Works ──────────────────────────────────────
            TextButton.icon(
              onPressed: () => OnboardingScreen.showAsModal(context),
              icon: Icon(Icons.help_outline,
                  size: 15, color: CustomColors.primaryColor),
              label: Text(
                'How It Works',
                style: TextStyle(
                  color: CustomColors.primaryColor,
                  fontSize: w / 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}