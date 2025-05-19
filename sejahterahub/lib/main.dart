import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sejahterahub/views/splashscreen.dart';
import 'package:sejahterahub/views/login_views.dart';
import 'package:sejahterahub/views/register_views.dart';
import 'package:sejahterahub/views/Homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SejahteraHub',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
