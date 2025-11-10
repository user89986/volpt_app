import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/constants.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'Навигация по техникуму',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        useMaterial3: true,
      ),
      // если сессии нет → LoginScreen, иначе → HomeScreen
      home: session == null ? const LoginScreen() : const HomeScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home' : (_) => const HomeScreen(),
      },
    );
  }
}
