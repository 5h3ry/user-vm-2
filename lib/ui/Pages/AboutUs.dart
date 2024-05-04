import 'package:flutter/material.dart';
import 'package:vending_app/ui/Pages/ProfilePage.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffffcc00),
        centerTitle: true,
        title: Text(
          'About Us',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Column(
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
              'Older vending machines often only accept cash, causing inconvenience for customers whoprefer cashless payments. Their outdated user interfaces can be confusing. They are also prone to security risks like theft and vandalism.To tackle these issues, we are adopting innovative solutions such as smart technologies,improved payment methods, and user-friendly interfaces. The continuous development ofadvanced vending machines aims to provide a better experience for both customers andoperators by offering more convenience and security.',
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
