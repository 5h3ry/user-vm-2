import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_app/ui/Drawer/drawer_side.dart';
import 'package:vending_app/ui/MachineIntro/item_list_screen.dart';


class SelectMachineForItems extends StatefulWidget {
  const SelectMachineForItems({Key? key});

  @override
  State<SelectMachineForItems> createState() => _SelectMachineForItemsState();
}

class _SelectMachineForItemsState extends State<SelectMachineForItems> {
  final auth = FirebaseAuth.instance;
  final searchController = TextEditingController();
  final fireStore = FirebaseFirestore.instance.collection('Machines').snapshots();
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  Future<void> initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }
  Future<void> displayQRCode(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? qrData = prefs.getString('qrData');

    if (qrData != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
              SizedBox(height: 20),
              Text(
                'Scan the QR code to proceed.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text('No QR code found. Please generate one first.'),
        ),
      );
    }
  }

  String getMachineId(DocumentSnapshot doc) {
    return doc['id'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerSide(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Color(0xffffcc00),
              automaticallyImplyLeading: false,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ],
              ),
              // title: const Text('Select Machine'),
              // centerTitle: true,

              expandedHeight: 150,
              flexibleSpace: FlexibleSpaceBar(
                background: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                    ),
                    items: [
                      Image.asset('assets/biscuitbanner.png'),
                      Image.asset('assets/milkbanner.png'),
                      Image.asset('assets/chocobanner.png'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by item name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (String value) {
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: fireStore,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No machines found'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var machineDoc = snapshot.data!.docs[index];
                      var machineId = getMachineId(machineDoc);
                      var machineName = machineDoc['machineName'].toString();
                      var location = machineDoc['location'].toString();
                      var imageUrl = machineDoc['imageUrl'].toString();

                      if (searchController.text.isNotEmpty) {
                        var subcollectionQuery = FirebaseFirestore.instance
                            .collection('Machines')
                            .doc(machineDoc.id)
                            .collection('items')
                            .where('itemName',
                            isGreaterThanOrEqualTo: searchController.text
                                .toUpperCase())
                            .where('itemName',
                            isLessThanOrEqualTo: searchController.text
                                .toUpperCase() + '\uf8ff');
                        return StreamBuilder<QuerySnapshot>(
                          stream: subcollectionQuery.snapshots(),
                          builder: (context, subSnapshot) {
                            if (subSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox
                                  .shrink(); // Hide the item if subcollection data is loading
                            }

                            if (subSnapshot.hasError) {
                              return SizedBox
                                  .shrink(); // Hide the item if there's an error
                            }

                            if (!subSnapshot.hasData ||
                                subSnapshot.data!.docs.isEmpty) {
                              return SizedBox
                                  .shrink(); // Hide the item if subcollection is empty
                            }

                            // Show the item if subcollection has matching data
                            return buildMachineCard(
                                machineName, location, imageUrl, machineId);
                          },
                        );
                      }

                      // If search text is empty, show the item without checking subcollection
                      return buildMachineCard(
                          machineName, location, imageUrl, machineId);
                    },
                  );
                },
              ),
            ),
          ],
        ),

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
            label: "Order Summary",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack),
            label: "Last Order",
          ),
        ],
      ),
    );
  }

  int _currentIndex = 0;

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
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => SelectMachineForItems()));
  }
  void onCartTapped() {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          // Handle Android system back button
          onWillPop: () async {
            setState(() {
              _currentIndex = 0; // Set currentIndex to 0
            });
            return true; // Allow dialog to be closed
          },
          child: AlertDialog(
            title: Text("Select a Machine"),
            content: Text("Please select a machine before proceeding to the cart."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0; // Set currentIndex to 0
                  });
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }

  void onOrdersTapped() {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          // Handle Android system back button
          onWillPop: () async {
            setState(() {
              _currentIndex = 0; // Set currentIndex to 0
            });
            return true; // Allow dialog to be closed
          },
          child: AlertDialog(
            title: Text("Select a Machine"),
            content: Text("Please select a machine before proceeding to the Order."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0; // Set currentIndex to 0
                  });
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }

  void onProfileTapped() {
    // Ensure SharedPreferences has been initialized
    if (_prefs == null) {
      return;
    }

    // Retrieve QR code data from SharedPreferences
    String? qrData = _prefs!.getString('qrData');

    if (qrData != null) {
      showDialog(
        context: context,
        barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
        builder: (_) => AlertDialog(
          content: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {}, // Prevent dialog from closing when tapped
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                SizedBox(height: 20),
                Text(
                  'Scan the QR code to proceed.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0; // Set currentIndex to 0
                    });
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // If QR data is not found, show a message or handle accordingly
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text('No QR code found. Please generate one first.'),
        ),
      );
    }
  }

  Widget buildMachineCard(String machineName, String location, String imageUrl,
      String machineId) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ItemListScreen(machineId: machineId)),
          );
        },
        title: Text(
          machineName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Location: $location'),
        leading: imageUrl.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        )
            : Container(
             width: 80,
             height: 80,
             color: Colors.grey[300],

               child: Center(
                  child: Icon(
                Icons.image,
                color: Colors.grey[600],
                size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
