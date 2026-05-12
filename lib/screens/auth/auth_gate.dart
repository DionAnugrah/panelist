import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import 'login_screen.dart';
import 'update_password_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() =>
      _AuthGateState();
}

class _AuthGateState
    extends State<AuthGate> {

  bool isRecovery = false;

  @override
  void initState() {
    super.initState();

    checkRecovery();
  }

  void checkRecovery() {

    Supabase.instance.client.auth
        .onAuthStateChange
        .listen((data) {

      final event = data.event;

      // DETEKSI RECOVERY PASSWORD
      if (event == AuthChangeEvent.passwordRecovery) {

        setState(() {
          isRecovery = true;
        });

      }

    });
  }

  @override
  Widget build(BuildContext context) {

    // JIKA RECOVERY PASSWORD
    if (isRecovery) {
      return const UpdatePasswordScreen();
    }

    final session =
        Supabase.instance.client.auth.currentSession;

    // JIKA SUDAH LOGIN
    if (session != null) {
      return const MainNavigation();
    }

    // JIKA BELUM LOGIN
    return const LoginScreen();
  }
}