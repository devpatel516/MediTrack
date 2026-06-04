import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void initState(){
    super.initState();
    Timer(const Duration(seconds: 3),(){
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context)=>LoginScreen())
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/meditrack.png',height: 150,),
            const SizedBox(height: 30,),
            const CircularProgressIndicator(color:Color.fromRGBO(
                44, 162, 158, 1.0))
          ],
        ),
      )
    );
  }
}


