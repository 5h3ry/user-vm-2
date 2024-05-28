import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class refferFriend extends StatelessWidget {
  const refferFriend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffffcc00),
        centerTitle: true,
        title: const Text(
          'Refer Friend\'s',
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
              'It’s a win-win situation! Spread the word about our advanced vending machines and enjoy the benefits together. Start referring today and experience the future of convenient, secure, and smart vending solutions with your friends!',
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
