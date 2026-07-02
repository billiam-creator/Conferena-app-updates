import 'package:flutter/material.dart';
import 'package:ticketkona/services/settings_manager.dart';
import 'package:ticketkona/theme/colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _soundEnabled     = true;
  bool _vibrationEnabled = true;
  String _themeMode      = 'system';
  bool _loading          = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsManager.loadAll();
    if (!mounted) return;
    setState(() {
      _soundEnabled     = settings.soundEnabled;
      _vibrationEnabled = settings.vibrationEnabled;
      _themeMode        = settings.themeString;
      _loading          = false;
    });
  }

  Future<void> _setSound(bool val) async {
    setState(() => _soundEnabled = val);
    await SettingsManager.setSoundEnabled(val);
  }

  Future<void> _setVibration(bool val) async {
    setState(() => _vibrationEnabled = val);
    await SettingsManager.setVibrationEnabled(val);
  }

  Future<void> _setTheme(String val) async {
    setState(() => _themeMode = val);
    await SettingsManager.setThemeMode(val);
    // Notify root MyApp to rebuild with new ThemeMode
    final provider = AppSettingsProvider.of(context);
    if (provider != null) {
      final updated = provider.settings.copyWith(themeString: val);
      provider.onChanged(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                _SectionLabel('Scan Feedback'),

                _SettingsCard(
                  children: [
                    SwitchListTile(
                      value: _soundEnabled,
                      activeColor: CustomColors.primaryColor,
                      title: Text(
                        'Sound',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Play a beep on scan result',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                      secondary: Icon(
                        Icons.volume_up_outlined,
                        color: CustomColors.primaryColor,
                      ),
                      onChanged: _setSound,
                    ),
                    Divider(height: 1, color: isDark ? Colors.white12 : null),
                    SwitchListTile(
                      value: _vibrationEnabled,
                      activeColor: CustomColors.primaryColor,
                      title: Text(
                        'Vibration',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Vibrate on scan result',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                      secondary: Icon(
                        Icons.vibration,
                        color: CustomColors.primaryColor,
                      ),
                      onChanged: _setVibration,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _SectionLabel('Appearance'),

                _SettingsCard(
                  children: [
                    _ThemeOption(
                      label: 'Light',
                      icon: Icons.light_mode_outlined,
                      selected: _themeMode == 'light',
                      onTap: () => _setTheme('light'),
                    ),
                    Divider(height: 1, color: isDark ? Colors.white12 : null),
                    _ThemeOption(
                      label: 'Dark',
                      icon: Icons.dark_mode_outlined,
                      selected: _themeMode == 'dark',
                      onTap: () => _setTheme('dark'),
                    ),
                    Divider(height: 1, color: isDark ? Colors.white12 : null),
                    _ThemeOption(
                      label: 'Follow device theme',
                      icon: Icons.brightness_auto_outlined,
                      selected: _themeMode == 'system',
                      onTap: () => _setTheme('system'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // App version info
                Center(
                  child: Text(
                    'Conferena v1.2.1',
                    style: TextStyle(
                      color: isDark ? Colors.white30 : Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
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

// ── Settings card ─────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ── Theme option row ──────────────────────────────────────────────────────────
class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon,
          color: selected ? CustomColors.primaryColor : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: CustomColors.primaryColor)
          : Icon(Icons.circle_outlined,
              color: isDark ? Colors.white30 : Colors.grey),
      onTap: onTap,
    );
  }
}