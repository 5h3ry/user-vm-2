import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffffcc00),
        centerTitle: true,
        title: const Text(
          'About Us',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Vend Vibe App!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Older vending machines often only accept cash, causing inconvenience for customers who prefer cashless payments. Additionally, their outdated user interfaces can be confusing, and they are prone to security risks like theft and vandalism. To tackle these issues, we are adopting innovative solutions such as smart technologies, advanced payment methods, and user-friendly interfaces. The continuous development of advanced vending machines aims to provide a better experience for both customers and operators by offering more convenience and enhanced security.',
              style: TextStyle(fontSize: 16.5),
                textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16.0),

          ],
        ),
      ),
    );
  }
}
