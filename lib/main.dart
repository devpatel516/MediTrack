import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:internship/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_check.dart';
const Color brandTeal = Color.fromRGBO(44, 162, 158, 1.0);

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'appointment_channel',
        channelName: 'Appointments',
        channelDescription: 'Reminders for upcoming visits',
        defaultColor: const Color(0xFF2CA29E), // Your teal color!
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
  );

  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
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
      home:AuthCheck(),
    );
  }
}

