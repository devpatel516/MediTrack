import 'package:flutter/material.dart';
import 'package:internship/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'screens/splash_screen.dart';

const Color brandTeal = Color.fromRGBO(44, 162, 158, 1.0);

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediTrack',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blueAccent),
      ),
      home: LoginScreen(),
    );
  }
}

