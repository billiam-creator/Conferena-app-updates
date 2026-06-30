import 'package:flutter/material.dart';
import 'package:ticketkona/theme/colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Placeholder state — wired up to SharedPreferences on Friday
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  String themeMode = 'System'; // Light / Dark / System

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightGreyScaffold,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: CustomColors.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _SectionLabel('Scan Feedback'),

          _SettingsCard(
            children: [
              SwitchListTile(
                value: soundEnabled,
                activeColor: CustomColors.primaryColor,
                title: const Text('Sound'),
                subtitle: const Text('Play a sound on scan result'),
                onChanged: (val) => setState(() => soundEnabled = val),
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: vibrationEnabled,
                activeColor: CustomColors.primaryColor,
                title: const Text('Vibration'),
                subtitle: const Text('Vibrate on scan result'),
                onChanged: (val) => setState(() => vibrationEnabled = val),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SectionLabel('Appearance'),

          _SettingsCard(
            children: [
              _ThemeOption(
                label: 'Light',
                selected: themeMode == 'Light',
                onTap: () => setState(() => themeMode = 'Light'),
              ),
              const Divider(height: 1),
              _ThemeOption(
                label: 'Dark',
                selected: themeMode == 'Dark',
                onTap: () => setState(() => themeMode = 'Dark'),
              ),
              const Divider(height: 1),
              _ThemeOption(
                label: 'Follow device theme',
                selected: themeMode == 'System',
                onTap: () => setState(() => themeMode = 'System'),
              ),
            ],
          ),

        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle, color: CustomColors.primaryColor)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: onTap,
    );
  }
}
