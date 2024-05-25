
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  SharedPreferences? _prefs;

  @override



  @override
  void initState() {
    super.initState();
    _loadSelectedItems();
    initializeSharedPreferences();

  }
  Future<void> initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
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

  int _currentIndex = 1;

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
    } else {setState(() {
      _currentIndex = 1; // Set currentIndex to 0
    });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty!')),
      );
    }
  }

  void onOrdersTapped() {
    if (cartItemCount > 0) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(
            selectedIds: selectedIds, machineId: widget.machineId),
      ),
    );
  } else {setState(() {
      _currentIndex = 1; // Set currentIndex to 0
    });
  ScaffoldMessenger.of(context).showSnackBar(

  SnackBar(content: Text('Your cart is empty!\nNo Order Summary available')),
  );
  }
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
                      _currentIndex = 1; // Set currentIndex to 0
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
/*
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

 */
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

        bool isQuantityZero = quantity == '0';

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
              onPressed: isQuantityZero ? null : () {
                addToCart(id);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  isQuantityZero ? Colors.grey : (isSelected ? Colors.red : Colors.green),
                ),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
