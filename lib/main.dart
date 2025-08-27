// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_project3/pages/login_page.dart';
import 'package:flutter_project3/supabase/supabase_connect.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase menggunakan konfigurasi dari .env
    await DatabaseConfig.initialize();
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
    // Tampilkan layar error jika inisialisasi gagal (opsional)
    runApp(const ErrorApp());
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal Kegiatan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A4877),
          foregroundColor: Colors.white,
        ),
      ),
      home: const Login(), // Mulai dengan halaman login
    );
  }
}

// Layar error jika inisialisasi gagal (opsional)
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Gagal menginisialisasi aplikasi. Periksa konfigurasi Supabase.',
            style: TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
