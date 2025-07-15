import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:notscrd/screens/main_nav_scrren.dart';
import 'package:notscrd/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    // DevicePreview(builder: (context) => MyApp(initialDarkMode: isDarkMode)),
    MyApp(initialDarkMode: isDarkMode),
  );
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;
  const MyApp({super.key, required this.initialDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    _isDarkMode = widget.initialDarkMode;
    super.initState();
  }

  void _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Books',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainNavScreen(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleDarkMode,
      ),
    );
  }
}
