import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';
import 'package:vending_app/ui/auth/login_screen.dart';

class SplashServices {
  Future<void> isLogin(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    await Timer(const Duration(seconds: 3), () {
      if (user != null) {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>SelectMachineForItems() ),);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }
}
