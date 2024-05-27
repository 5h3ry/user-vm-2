import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../firebase_services/splash_services.dart';

class SliderPage extends StatefulWidget {
  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  SplashServices splashServices = SplashServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffcc00),
      body: CarouselSlider(
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height, // Set height to full screen height
          autoPlay: true,
          enlargeCenterPage: true,
        ),
        items: [
          'assets/chocolateslider.png',
          'assets/biscuitslider.png',
          'assets/milkslider.png',
        ].map((item) {
          return Builder(
            builder: (BuildContext context) {
              return Image.asset(
                item,
                fit: BoxFit.cover,
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          splashServices.isLogin(context).then((_) {
          });
        },
        label: const Text('Start'),
        icon: const Icon(Icons.arrow_right),
        backgroundColor: Colors.orangeAccent,
        elevation: 10,
      ),
    );
  }
}
