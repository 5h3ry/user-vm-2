import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';
import 'package:vending_app/ui/Pages/ProfilePage.dart';

class DrawerSide extends StatefulWidget {
  const DrawerSide({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DrawerSideState createState() => _DrawerSideState();
}

class _DrawerSideState extends State<DrawerSide> {
  Color textColor = Colors.black;
  Color primaryColor = Colors.white;

  late String _imagePath;
  File? _image;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _userEmail = "";
  late final String _userName = "User's Email:";

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _userEmail = user.email ?? ""; // Fetch user's email
      });

      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(user.uid).get();

      if (snapshot.exists) {
        setState(() {
          _imagePath = snapshot.data()?['profile_image_path'] ?? '';
          if (_imagePath.isNotEmpty) {
            _image = File(_imagePath);
          } else {
            _image = null; // Clear the image if path is empty
          }
        });
      }
    }
  }

  Widget listTile({
    String title = "",
    IconData? iconData,
    Color? backgroundColor,
    void Function()? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: Colors.grey[300]!), // Add a bottom border
        ),
      ),
      child: ListTile(
        onTap: onTap,
        tileColor: backgroundColor ?? Colors.white,
        trailing: const Icon(Icons.arrow_forward_ios),
        leading: Icon(
          iconData ?? Icons.error,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Replace the following lines with your actual user data retrieval logic
    var userData = UserData(
      userName: _userName,
      userEmail: _userEmail, // Use the fetched user email here
      userImage: "assets/avatar.png", // Change to your local asset path
    );

    return Drawer(
      child: Container(
        color: primaryColor,
        child: ListView(
          children: [
            Container(
              color: const Color(0xffffcc00), // Set the background color to yellow
              child: DrawerHeader(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 45, // Increased size
                        backgroundColor: primaryColor,
                        child: CircleAvatar(
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : const AssetImage("assets/avatar.png")
                          as ImageProvider,
                          radius: 42, // Adjusted size
                          backgroundColor: Colors.black12,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userData.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            userData.userEmail,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            listTile(
              iconData: Icons.home_outlined,
              title: "Home",
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SelectMachineForItems()));
              },
            ),
            listTile(
              iconData: Icons.shopping_cart,
              title: "My Cart",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Select a Machine"),
                      content: const Text(
                          "Please select a machine before proceeding to the cart."),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            // setState(() {
                            //   _currentIndex = 3;
                            // });
                            Navigator.of(context).pop();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            listTile(
              iconData: Icons.shop_outlined,
              title: "My Orders",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Select a Machine"),
                      content: const Text(
                          "Please select a machine before proceeding to the Order."),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            // setState(() {
                            //   _currentIndex = 3;
                            // });
                            Navigator.of(context).pop();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            listTile(
              iconData: Icons.person_outlined,
              title: "My Profile",
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()));
              },
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              height: 350,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contact Support",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20, // Change the font size according to your preference
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        "Call us:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15, // Change the font size according to your preference
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("+923352580282"),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          "Mail us:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Change the font size according to your preference
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "vendvibe@gmail.com",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UserData {
  final String userName;
  final String userEmail;
  final String userImage;

  UserData({
    required this.userName,
    required this.userEmail,
    required this.userImage,
  });
}
