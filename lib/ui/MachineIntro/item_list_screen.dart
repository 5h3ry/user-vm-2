/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vending_app/ui/MachineIntro/cart_page.dart';
import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';
import 'package:flutter/material.dart';


class ItemListScreen extends StatefulWidget {
  final String machineId;

  ItemListScreen({required this.machineId});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final auth = FirebaseAuth.instance;
  List<String> selectedIds = [];
  int cartItemCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFCC00),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Items List'),
            SizedBox(width: 10),
            buildCartIcon(),
          ],
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Machines')
            .doc(widget.machineId)
            .collection('items')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data found'));
          }
          return ListView(
            children: buildListTilesFromSubcollection(snapshot.data!),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
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
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>selectMachineForItems() ),);
  }

  void onCartTapped() {
    if (cartItemCount > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartPage(selectedIds: selectedIds, machineId: widget.machineId),
        ),
      );


    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty!')),
      );
    }
  }

  void onOrdersTapped() {
    // Handle Orders icon tap
    print("Orders tapped");
  }

  void onProfileTapped() {
    // Handle Profile icon tap
    print("Profile tapped");
  }


  Widget buildCartIcon() {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            if (cartItemCount > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(selectedIds: selectedIds, machineId: widget.machineId),
                ),
              );


            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Your cart is empty!')),
              );
            }
          },
          icon: Icon(Icons.shopping_cart),
        ),
        cartItemCount > 0
            ? Positioned(
          right: 8,
          top: 8,
                 child: CircleAvatar(
            backgroundColor: Colors.red,
            radius: 10,
                   child: Text(
              cartItemCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        )
            : SizedBox(),
      ],
    );
  }

  void addToCart(String id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
        cartItemCount--;
      } else {
        selectedIds.add(id);
        cartItemCount++;
      }
    });
  }

  List<Widget> buildListTilesFromSubcollection(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        String id = doc.id;
        String itemName = data['itemName'] ?? '';
        String price = data['price'] ?? '';
        String quantity = data['quantity'] ?? '';
        String imageUrl = data['imageUrl'] ?? '';
        bool isSelected = selectedIds.contains(id);
        return ListTile(
          leading: imageUrl.isNotEmpty ? Image.network(imageUrl) : SizedBox(),
          title: Text(itemName),
          subtitle: Text('Price: $price, Quantity: $quantity'),
          trailing: ElevatedButton(
            onPressed: () {
              addToCart(id);
            },
            child: Text(isSelected ? 'Remove from Cart' : 'Add to Cart'),
          ),
        );
      } else {
        return SizedBox();
      }
    }).toList();
  }
}

*/

//7commit


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vending_app/ui/MachineIntro/cart_page.dart';
import 'package:vending_app/ui/MachineIntro/orders.dart';
import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_app/ui/Pages/ProfilePage.dart';

class ItemListScreen extends StatefulWidget {
  final String machineId;

  ItemListScreen({required this.machineId});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final auth = FirebaseAuth.instance;
  List<String> selectedIds = [];
  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSelectedItems();
  }

  _loadSelectedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedItems = prefs.getStringList(widget.machineId);
    if (storedItems != null) {
      setState(() {
        selectedIds = storedItems;
        cartItemCount = storedItems.length;
      });
    }
  }

  _saveSelectedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(widget.machineId, selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFCC00),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Items List'),
            SizedBox(width: 10),

          ],

        ),
        actions: [
          buildCartIcon(context),
        ],
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Machines')
            .doc(widget.machineId)
            .collection('items')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data found'));
          }
          return ListView(
            children: buildListTilesFromSubcollection(snapshot.data!),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SelectMachineForItems()),
    );
  }

  void onCartTapped() {
    if (cartItemCount > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CartPage(selectedIds: selectedIds, machineId: widget.machineId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty!')),
      );
    }
  }

  void onOrdersTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(
            selectedIds: selectedIds, machineId: widget.machineId),
      ),
    );
  }

  void onProfileTapped() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));

  }

  Widget buildCartIcon(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (cartItemCount > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(
                selectedIds: selectedIds,
                machineId: widget.machineId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Your cart is empty!')),
          );
        }
      },
      icon: Stack(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 30, // Adjust the size of the shopping bag icon
          ),
          if (cartItemCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 8, // Adjust the radius to decrease badge size
                child: Text(
                  cartItemCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10, // Adjust the font size of the badge text
                  ),
                ),
              ),
            ),
        ],
      ),
    );

  }


  void addToCart(String id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
        cartItemCount--;
      } else {
        selectedIds.add(id);
        cartItemCount++;
      }
    });
    _saveSelectedItems();
  }

  List<Widget> buildListTilesFromSubcollection(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        String id = doc.id;
        String itemName = data['itemName'] ?? '';
        String price = data['price'] ?? '';
        String quantity = data['quantity'] ?? '';
        String imageUrl = data['imageUrl'] ?? '';
        bool isSelected = selectedIds.contains(id);
        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            contentPadding: EdgeInsets.all(14),
            leading: imageUrl.isNotEmpty
                ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: Colors.black),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 60,
                  height: 100,
                ),
              ),
            )
                : SizedBox(width: 80, height: 80),
            title: Text(
              itemName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            subtitle: Text(
              'Price: $price\nQuantity: $quantity',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                addToCart(id);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  isSelected ? Colors.red : Colors.green,
                ),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 12), // Adjust font size
                ),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjust padding
                ),
              ),
              child: Text(
                isSelected ? 'Remove from Cart' : 'Add to Cart',
                style: TextStyle(color: Colors.white),
              ),
            ),

          ),
        );

      } else {
        return SizedBox();
      }
    }).toList();
  }
}
