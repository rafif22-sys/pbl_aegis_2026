import 'package:flutter/material.dart';
import 'supervisor/home_page.dart'; // Mengambil file desainmu

void main() {
  runApp(const AegisApp());
}

class AegisApp extends StatelessWidget {
  const AegisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis Supervisor',
      debugShowCheckedModeBanner: false, // Menghilangkan pita merah "DEBUG" di pojok kanan atas
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Di sinilah keajaibannya, kita atur halaman awalnya ke SupervisorHomePage!
      home: const SupervisorHomePage(), 
    );
  }
}