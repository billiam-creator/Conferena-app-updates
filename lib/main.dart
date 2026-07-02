import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ticketkona/screens/initializer.dart';
import 'package:ticketkona/services/settings_manager.dart';
import 'package:ticketkona/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load persisted settings before first frame so theme is applied immediately
  final settings = await SettingsManager.loadAll();

  runApp(MyApp(initialSettings: settings));
}

class MyApp extends StatefulWidget {
  final AppSettings initialSettings;
  const MyApp({super.key, required this.initialSettings});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  void _onSettingsChanged(AppSettings updated) {
    setState(() => _settings = updated);
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsProvider(
      settings: _settings,
      onChanged: _onSettingsChanged,
      child: MaterialApp(
        title: 'CONFERENA',
        debugShowCheckedModeBanner: false,
        themeMode: _settings.themeMode,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const Initializer(),
      ),
    );
  }
}