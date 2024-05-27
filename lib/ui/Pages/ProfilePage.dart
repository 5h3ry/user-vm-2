import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';
import 'package:vending_app/ui/Pages/AboutUs.dart';
import 'package:vending_app/ui/auth/login_screen.dart';
import '../Drawer/drawer_side.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Color primaryColor = Colors.white;
  Color textColor = Colors.black;
  Color scaffoldBackgroundColor = Color(0xffffcc00);

  late SharedPreferences _prefs;
  late String _imagePath;
  File? _image;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(user.uid).get();

      if (snapshot.exists) {
        setState(() {
          _imagePath = snapshot.data()?['profile_image_path'] ?? '';
          if (_imagePath.isNotEmpty) {
            _image = File(_imagePath);
          }
        });
      }
    }
  }

  Future<void> _saveImage(String imagePath) async {
    final User? user = _auth.currentUser;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'profile_image_path': imagePath,
      });
    }
  }

  Future<void> getImage() async {
    final pickedFile =
    await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });
      _saveImage(imageFile.path);
    }
  }

  void _removeImage() async {
    setState(() {
      _image = null;
    });

    final User? user = _auth.currentUser;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'profile_image_path': FieldValue.delete(),
      });
    }

    if (_imagePath.isNotEmpty) {
      final File imageFile = File(_imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "My Profile",
          style: TextStyle(
            color: textColor,
          ),
        ),
      ),
      drawer: DrawerSide(),

      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 60,
                color: scaffoldBackgroundColor,
              ),
              Container(
                height: 450,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 250,
                          height: 110,
                          padding: EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Your existing code
                            ],
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'User Name: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: _auth.currentUser?.email ?? 'User Name:',
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    listTile(
                      icon: Icons.person_outline,
                      title: "Refer A Friend",
                      backgroundColor: Colors.white,
                    ),
                    listTile(
                      icon: Icons.add_chart,
                      title: "About Us",
                      backgroundColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AboutUs()),
                        );
                      },
                    ),
                    listTile(
                      icon: Icons.file_copy_outlined,
                      title: "Help",
                      backgroundColor: Colors.white,
                    ),
                    listTile(
                      icon: Icons.exit_to_app_outlined,
                      title: "Log Out",
                      backgroundColor: Colors.white,
                      // onTap: () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => LoginScreen()),
                      //   );
                      // },
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 25,
            left: (MediaQuery.of(context).size.width - 160) / 2, // Centering the avatar
            child: GestureDetector(
              onTap: () {
                _showPopupMenu(context);
              },
              child: CircleAvatar(
                radius: 80, // Increased size
                backgroundColor: primaryColor,
                child: CircleAvatar(
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : AssetImage("assets/avatar.png") as ImageProvider,
                  radius: 75, // Adjusted size
                  backgroundColor: Colors.black12,
                ),
              ),
            ),
          ),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "My Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "My Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  int _currentIndex = 3;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle tap events for each tab
    switch (index) {
      case 0:
        onHomeTapped();
        break;
      case 1:
        onCartTapped();
        break;
      case 2:
        onOrdersTapped();
        break;
      case 3:
        onProfileTapped();
        break;
    }
  }

  void onHomeTapped() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SelectMachineForItems()));
  }

  void onCartTapped() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a Machine"),
          content:
          Text("Please select a machine before proceeding to the cart."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 3;
                });
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void onOrdersTapped() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a Machine"),
          content:
          Text("Please select a machine before proceeding to the Order."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 3;
                });
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void onProfileTapped() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  Widget listTile({
    IconData? icon,
    String? title,
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return Column(
      children: [
        Divider(
          height: 1,
        ),
        ListTile(
          leading: Icon(icon ?? Icons.error),
          title: Text(title ?? ""),
          tileColor: backgroundColor ?? Colors.blue,
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: onTap,
        )
      ],
    );
  }

  void _showPopupMenu(BuildContext context) async {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RenderBox circleAvatarBox = context.findRenderObject() as RenderBox;
    final Offset targetPosition = circleAvatarBox.localToGlobal(Offset.zero, ancestor: overlay);

    final selectedOption = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        targetPosition.dx,
        targetPosition.dy + circleAvatarBox.size.height,
        targetPosition.dx + circleAvatarBox.size.width,
        targetPosition.dy + circleAvatarBox.size.height + 50,
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.image),
            title: Text('Select Image'),
            onTap: getImage,
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.remove_circle),
            title: Text('Remove Image'),
            onTap: () {
              _removeImage();
              Navigator.pop(context);
            },
          ),
        ),
      ],
      elevation: 8.0,
    );
  }
}
