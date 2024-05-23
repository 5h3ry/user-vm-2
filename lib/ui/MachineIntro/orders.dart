
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_app/ui/MachineIntro/cart_page.dart';
import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vending_app/ui/Pages/ProfilePage.dart';
import 'package:flutter/rendering.dart';


class OrderPage extends StatefulWidget {
  final List<String> selectedIds;
  final String machineId;
  OrderPage({required this.selectedIds, required this.machineId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Future<List<Map<String, dynamic>>> _selectedItemsFuture;
  late SharedPreferences _prefs; // Add SharedPreferences instance
  final fireStore = FirebaseFirestore.instance.collection('Orders');
  final GlobalKey _globalKey = GlobalKey();
  bool loading = false;

  Map<String, String> itemQuantities = {};
  double totalBill = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedItemsFuture = _fetchSelectedItems();
    _initSharedPreferences(); // Initialize SharedPreferences
  }



  // Method to initialize SharedPreferences
  _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadItemQuantities(); // Load item quantities from SharedPreferences
  }

  // Method to load item quantities from SharedPreferences
  _loadItemQuantities() {
    for (String id in widget.selectedIds) {
      String? quantity = _prefs.getString(id);
      if (quantity != null) {
        itemQuantities[id] = quantity;
      } else {
        itemQuantities[id] = '1'; // Set default quantity if not found
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSelectedItems() async {
    List<Map<String, dynamic>> selectedItemsData = [];
    await Future.forEach(widget.selectedIds, (String id) async {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Machines')
          .doc(widget.machineId)
          .collection('items')
          .doc(id)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        selectedItemsData.add(data);
      }
    });
    return selectedItemsData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFCC00),
        title: Text('Order'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _selectedItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Order placed yet'));
          } else {
            totalBill = 0.0;
            for (int index = 0; index < snapshot.data!.length; index++) {
              Map<String, dynamic> itemData = snapshot.data![index];
              String itemId = widget.selectedIds[index];
              int quantity = int.parse(itemQuantities[itemId] ?? '1');
              double price = double.parse(itemData['price'].toString());
              double itemTotal = price * quantity;
              totalBill += itemTotal;
            }
            return Column(
              children: [
                Text(
                  'ORDER SUMMARY',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> itemData = snapshot.data![index];
                      String itemId = widget.selectedIds[index];
                      int quantity = int.parse(itemQuantities[itemId] ?? '1');
                      String imageUrl = itemData['imageUrl'] ?? '';

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemData['itemName'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Price: ${itemData['price']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Quantity: $quantity',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Total: ${int.parse(itemData['price']) * quantity}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Bill:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'Rs.${totalBill.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    addSubCollection(); // Call addSubCollection to handle everything including QR code generation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Background color
                    textStyle: TextStyle(fontWeight: FontWeight.bold), // Button text style
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corner radius
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30), // Button padding
                  ),
                  child: Text(
                    'QR Generator',
                    style: TextStyle(fontSize: 18, color: Colors.white), // Text style
                  ),
                ),
              ],
            );
          }
        },
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

  int _currentIndex = 2;

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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          selectedIds: widget.selectedIds,
          machineId: widget.machineId,
        ),
      ),
    );
  }

  void onOrdersTapped() {}

  void onProfileTapped() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  void _generateQRCode(String machineId, String subDocId, Map<String, String> itemQuantities) {
    // Generate QR code with machineId, subDocId, and itemIds with quantities
    String qrData = 'Machine ID: $machineId\n';
    qrData += 'Order ID: $subDocId\n';
    qrData += 'Items:\n';
    itemQuantities.forEach((itemId, quantity) {
      qrData += '  $itemId: $quantity\n';
    });

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
  }





  void addSubCollection() async {
    String subDocId = DateTime.now().millisecondsSinceEpoch.toString();

    await fireStore.doc(subDocId).set({
      'fulfilled': false,
      'id': subDocId,
    });

    // Prepare the data for the items sub-collection
    Map<String, String> itemsData = {};
    itemQuantities.forEach((itemId, quantity) {
      itemsData[itemId] = quantity;
    });

    // Add item data to Firestore
    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(subDocId)
        .collection('items')
        .doc(subDocId)
        .set({
      ...itemsData,
      'id': subDocId,
    });

    // Generate the QR code with the machineId and subDocId
    _generateQRCode(widget.machineId, subDocId, itemQuantities);
  }



}



