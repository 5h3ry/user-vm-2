import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vending_app/ui/IntroPages/sliderpage.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(primaryColor: Colors.black),
  home: SplashScreen(),
));

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 2),
          () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SliderPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [Color(0xFFFFFACD), Color(0xffffcc00)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Your App Logo
              Container(
                width: 300, // Increased size
                height: 300, // Increased size
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'assets/vending.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Animated Loading Indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFCC00)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
