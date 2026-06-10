import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'doctor_dashboard.dart';
import 'patient_dashboard.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Read the token and role from your secure storage
    String? token = await storage.read(key: 'jwt_token');
    String? role = await storage.read(key: 'user_role');
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    if (token != null && role != null) {
      if (role == 'doctor') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const DoctorDashboard()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const PatientDashboard()));
      }
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromRGBO(44, 162, 158, 1.0),
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}