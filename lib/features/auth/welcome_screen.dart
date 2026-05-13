import 'dart:async';

import 'package:flutter/material.dart';

import '../../main.dart';

class WelcomeScreen extends StatefulWidget {
  final String username;

  const WelcomeScreen({super.key, required this.username});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/icon.png', width: 100, height: 100),

            const SizedBox(height: 30),

            Text(
              "Selamat Datang",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              widget.username,
              style: TextStyle(fontSize: 18, color: scheme.onSurfaceVariant),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
