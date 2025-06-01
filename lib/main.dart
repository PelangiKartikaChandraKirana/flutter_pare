import 'package:flutter/material.dart';
import 'package:pareverse/screens/onboarding_screen.dart';
import 'package:pareverse/screens/login_screen.dart';
import 'package:pareverse/screens/register_screen.dart';
import 'package:pareverse/screens/home_screen.dart';
import 'package:pareverse/screens/favorite_screen.dart';
import 'package:pareverse/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pareverse',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/onboarding', // Selalu mulai dari onboarding
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/favorite': (context) => const FavoriteScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}