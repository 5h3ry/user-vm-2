import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_app/ui/MachineIntro/orders.dart';
import 'select_machine_for_item.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CartPage extends StatefulWidget {
  final List<String> selectedIds;
  final String machineId;

  const CartPage({super.key, required this.selectedIds, required this.machineId});

  @override
  // ignore: library_private_types_in_public_api
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<Map<String, dynamic>>> _selectedItemsFuture;
  late SharedPreferences _prefs; // Add SharedPreferences instance

  Map<String, String> itemQuantities = {};
  double totalBill = 0.0;
  //SharedPreferences? _prefs;



  Future<void> initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }
  @override
  void initState() {
    super.initState();
    _selectedItemsFuture = _fetchSelectedItems();
    _initSharedPreferences(); // Initialize SharedPreferences
    initializeSharedPreferences();

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

  Future<void> displayQRCode(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? qrData = prefs.getString('qrData');

    if (qrData != null) {
      showDialog(
        // ignore: use_build_context_synchronously
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
              const SizedBox(height: 20),
              const Text(
                'Scan the QR code to proceed.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (_) => const AlertDialog(
          content: Text('No QR code found. Please generate one first.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFCC00),
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _selectedItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found in the cart'));
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
                         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                         child: ListTile(
                           contentPadding: const EdgeInsets.all(10),
                           leading: imageUrl.isNotEmpty
                               ? Container(
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(5.0),
                               border: Border.all(color: Colors.black),
                               boxShadow: const [
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

                             : const SizedBox(),
                           title: Text(
                             itemData['itemName'],
                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                           ),
                           subtitle: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const SizedBox(height: 4),
                               Text(
                                 'Price: ${itemData['price']}',
                                 style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                               ),
                               Text(
                                 'Available Quantity: ${itemData['quantity']}',
                                 style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                               ),
                             ],
                           ),
                           trailing: Container(
                             width: 130,
                             height: 40,
                             decoration: BoxDecoration(
                               color: Colors.black54,
                               borderRadius: BorderRadius.circular(13),
                             ),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceAround,
                               children: [
                                 IconButton(
                                   icon: const Icon(
                                     Icons.remove,
                                     color: Colors.white,
                                   ),
                                   onPressed: () {
                                     setState(() {
                                       if (quantity > 1) {
                                         quantity--;
                                         itemQuantities[itemId] = quantity.toString();
                                         _prefs.setString(itemId, quantity.toString());
                                       }
                                     });
                                   },
                                 ),
                                 Text(
                                   '$quantity',
                                   style: const TextStyle(
                                     fontSize: 16,
                                     color: Colors.white,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                                 IconButton(
                                   icon: const Icon(
                                     Icons.add,
                                     color: Colors.white,
                                   ),
                                   onPressed: () {
                                     setState(() {
                                       if (quantity < int.parse(itemData['quantity'])) {
                                         quantity++;
                                         itemQuantities[itemId] = quantity.toString();
                                         _prefs.setString(itemId, quantity.toString());
                                       }
                                     });
                                   },
                                 ),
                               ],
                             ),
                           ),
                         ),
                       );

                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Bill:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'Rs.${totalBill.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderPage(
                          selectedIds: widget.selectedIds,
                          machineId: widget.machineId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Background color
                    textStyle: const TextStyle(fontWeight: FontWeight.bold), // Button text style
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corner radius
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30), // Button padding
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(fontSize: 18,color: Colors.white), // Text style
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
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>const SelectMachineForItems() ),);

  }

  void onCartTapped() {

  }

  void onOrdersTapped() {
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>OrderPage(selectedIds: widget.selectedIds , machineId: widget.machineId,) ),);

  }
  void onProfileTapped() {
    // Ensure SharedPreferences has been initialized
    // if (_prefs == null) {
    //   return;
    // }

    // Retrieve QR code data from SharedPreferences
    String? qrData = _prefs.getString('qrData');
//    String? qrData = _prefs!.getString('qrData');
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
                const SizedBox(height: 20),
                const Text(
                  'Scan the QR code to proceed.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1; // Set currentIndex to 0
                    });
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Close'),
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
        builder: (_) => const AlertDialog(
          content: Text('No QR code found. Please generate one first.'),
        ),
      );
    }
  }

}


