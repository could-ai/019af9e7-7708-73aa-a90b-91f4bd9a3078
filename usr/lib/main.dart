import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/translation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  // TODO: Replace with your actual Supabase URL and Anon Key after connecting a project
  try {
    await Supabase.initialize(
      url: 'https://your-project-url.supabase.co',
      anonKey: 'your-anon-key',
    );
  } catch (e) {
    // Handle initialization error or ignore if just previewing UI
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Translator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TranslationPage(),
      },
    );
  }
}
