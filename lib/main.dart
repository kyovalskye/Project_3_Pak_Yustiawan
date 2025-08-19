// main.dart
import 'package:flutter/material.dart';
import 'header.dart';
import 'body.dart';
import 'supabase/supabase_connect.dart';
import 'login.dart'; // ✅ import login page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal Kegiatan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Login(), // ✅ tampilkan login dulu
    );
  }
}

// ✅ Buat halaman utama terpisah
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: Header(),
      body: Body(),
    );
  }
}
