import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/profile/data/datasources/profile_records_data_source.dart';
import 'features/profile/presentation/state/profile_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MotionOrbitObjectBox.initialize();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motion Orbit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const StartupScreen(),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});
  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  final store = ProfileStore();
  String? error;
  bool corrupt = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool recover = false}) async {
    setState(() {
      error = null;
      corrupt = false;
    });
    try {
      if (recover) await store.recover();
      await store.load();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => store.profile != null
              ? DashboardScreen(store: store)
              : OnboardingScreen(store: store),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        corrupt = e is FormatException;
        error = corrupt
            ? 'Your saved setup could not be read. Retry, or start a new setup. The unreadable data will be kept on this device.'
            : 'Local storage is unavailable. Please retry. Setup needs working local storage to save your profile.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: error == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => _load(),
                      child: const Text('Retry'),
                    ),
                    if (corrupt)
                      TextButton(
                        onPressed: () => _load(recover: true),
                        child: const Text(
                          'Keep unreadable data and start new setup',
                        ),
                      ),
                  ],
                ),
        ),
      ),
    ),
  );
}
