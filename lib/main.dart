import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_project3/services/user_session.dart';
import 'package:flutter_project3/pages/login_page.dart'; // Adjust import path as needed
import 'package:flutter_project3/pages/body.dart';
import 'package:flutter_project3/widgets/header.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase BEFORE running the app
  await Supabase.initialize(
    url: 'https://xakbfanscyjlzwmdzabj.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhha2JmYW5zY3lqbHp3bWR6YWJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MDE4NjQsImV4cCI6MjA3MDQ3Nzg2NH0.dmmmCC7GnXMUbp4PyWo_muczhVCkYgYmV5TaHW0ebt0', // Replace with your Supabase anon key
  );

  // Load user session from SharedPreferences
  await UserSession.loadUserFromPrefs();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: UserSession.isLoggedIn()
          ? const Scaffold(body: Body(), appBar: Header())
          : const Login(), // Adjust class name as needed
      debugShowCheckedModeBanner: false,
    );
  }
}
