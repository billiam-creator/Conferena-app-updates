import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ticketkona/screens/chat_screen.dart';
import 'package:ticketkona/screens/onboarding_screen.dart';
import 'package:ticketkona/theme/colors.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const String phoneNumber  = '+254 729 334564';
  static const String emailAddress = 'digital@brainverse.co';
  static const _channel = MethodChannel('conferena/intent');

  Future<void> _openIntent(BuildContext context, String action, String data) async {
    try {
      await _channel.invokeMethod('open', {'action': action, 'data': data});
    } catch (e) {
      if (context.mounted) _showLinkDialog(context, data);
    }
  }

  void _showLinkDialog(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Contact'),
        content: SelectableText(value),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _call(BuildContext context) =>
      _openIntent(context, 'tel', phoneNumber);

  void _whatsapp(BuildContext context) {
    final number = phoneNumber.replaceAll('+', '');
    _openIntent(context, 'view', 'https://wa.me/$number');
  }

  void _email(BuildContext context) =>
      _openIntent(context, 'mailto', emailAddress);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white54 : Colors.grey;
    final labelColor = isDark ? Colors.white38 : Colors.grey[500];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Contact card ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  'CONTACT CONFERENA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: labelColor,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.phone, size: 18, color: CustomColors.primaryColor),
                    const SizedBox(width: 10),
                    Text(phoneNumber,
                        style: TextStyle(fontSize: 15, color: textPrimary)),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.email_outlined,
                        size: 18, color: CustomColors.primaryColor),
                    const SizedBox(width: 10),
                    Text(emailAddress,
                        style: TextStyle(fontSize: 15, color: textPrimary)),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomColors.primaryColor,
                          side: const BorderSide(color: CustomColors.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _call(context),
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Call'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _whatsapp(context),
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text('WhatsApp'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomColors.primaryColor,
                          side: const BorderSide(color: CustomColors.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _email(context),
                        icon: const Icon(Icons.email_outlined, size: 16),
                        label: const Text('Email'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _ActionTile(
            icon: Icons.headset_mic,
            title: 'Live Chat',
            subtitle: 'Chat with us now · powered by Tawk.to',
            filled: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),

          const SizedBox(height: 12),

          _ActionTile(
            icon: Icons.menu_book_outlined,
            title: 'How It Works',
            subtitle: 'Revisit the getting-started guide',
            filled: false,
            onTap: () => OnboardingScreen.showAsModal(context),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool filled;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unfFilledCard = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;

    return Material(
      color: filled ? CustomColors.primaryColor : unfFilledCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: filled
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.white24
                      : CustomColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: filled ? Colors.white : CustomColors.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: filled ? Colors.white : textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: filled
                            ? Colors.white70
                            : (isDark ? Colors.white38 : Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: filled
                    ? Colors.white70
                    : (isDark ? Colors.white30 : Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}