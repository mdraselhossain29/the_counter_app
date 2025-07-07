import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KHR Counter',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.black54,
            letterSpacing: 1.2,
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(16),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 8,
          backgroundColor: Colors.lightBlueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            letterSpacing: 1.2,
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(16),
          color: const Color(0xFF1E1E1E),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 8,
          backgroundColor: Colors.lightBlueAccent[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: CounterPage(onThemeToggle: _toggleTheme),
    );
  }
}

class CounterPage extends StatefulWidget {
  final Function(bool) onThemeToggle;
  const CounterPage({super.key, required this.onThemeToggle});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;
  bool _isDarkMode = false;
  bool _isHapticEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadCounter();
    _loadSettings();
  }

  void _playFeedback() async {
    if (!_isHapticEnabled) return;

    SystemSound.play(SystemSoundType.click);
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  void _increment() {
    setState(() {
      _counter++;
    });
    _saveCounter();
    _playFeedback();
  }

  void _decrement() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
    _saveCounter();
    _playFeedback();
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
    _saveCounter();
    _playFeedback();
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', _counter);
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('haptic', _isHapticEnabled);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _isHapticEnabled = prefs.getBool('haptic') ?? true;
    });
    widget.onThemeToggle(_isDarkMode);
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    widget.onThemeToggle(value);
    _saveSettings();
  }

  void _toggleHaptic(bool value) {
    setState(() {
      _isHapticEnabled = value;
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final buttonColor = isDark ? Colors.lightBlueAccent[400] : Colors.lightBlueAccent;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("KHR COUNTER", style: TextStyle(letterSpacing: 2.0)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isHapticEnabled ? Icons.vibration : Icons.vibration_outlined),
            onPressed: () => _toggleHaptic(!_isHapticEnabled),
            tooltip: 'Toggle haptic feedback',
          ),
          Switch(
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
            activeColor: Colors.lightBlueAccent,
            inactiveThumbColor: Colors.grey[300],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        "CURRENT COUNT",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          '$_counter',
                          key: ValueKey<int>(_counter),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: _counter < 0
                                ? Colors.redAccent
                                : _counter > 0
                                ? Colors.green
                                : theme.textTheme.headlineMedium?.color,
                            shadows: [
                              if (isDark)
                                Shadow(
                                  color: _counter < 0
                                      ? Colors.redAccent.withOpacity(0.4)
                                      : _counter > 0
                                      ? Colors.green.withOpacity(0.4)
                                      : Colors.lightBlueAccent.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 0),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'increment',
                    onPressed: _increment,
                    icon: const Icon(Icons.add, size: 24),
                    label: const Text("INCREASE",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    backgroundColor: buttonColor,
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'decrement',
                    onPressed: _decrement,
                    icon: const Icon(Icons.remove, size: 24),
                    label: const Text("DECREASE",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    backgroundColor: buttonColor,
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'reset',
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh, size: 24),
                    label: const Text("RESET",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    backgroundColor: buttonColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}