
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:vending_app/home.dart';
import 'package:vending_app/payment.dart';
import 'package:vending_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_app/ui/MachineIntro/cart_page.dart';
import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';



class OrderPage extends StatefulWidget {
  final List<String> selectedIds;
  final String machineId;
  const OrderPage({super.key, required this.selectedIds, required this.machineId});

  @override
  // ignore: library_private_types_in_public_api
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Future<List<Map<String, dynamic>>> _selectedItemsFuture;
  late SharedPreferences _prefs; // Add SharedPreferences instance
  final fireStore = FirebaseFirestore.instance.collection('Orders');
  bool loading = false;


  Future<void> initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }
  Map<String, String> itemQuantities = {};
  double totalBill = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedItemsFuture = _fetchSelectedItems();
    _initSharedPreferences(); // Initialize SharedPreferences
    initializeSharedPreferences();
  }
  @override
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
        backgroundColor: const Color(0xFFFFCC00),
        title: const Text('Order'),
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
            return const Center(child: Text('No Order placed yet'));
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
                const Text(
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

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
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
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
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
                                    const SizedBox(height: 4),
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
                        builder: (context) => HomePage(
                          machineId: widget.machineId,
                          selectedIds: widget.selectedIds,
                          totalBill: totalBill,
                        ),
                      ),
                    );
                   // _showPaymentForm(context);

                   // addSubCollection(); // Call addSubCollection to handle everything including QR code generation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Background color
                    textStyle: const TextStyle(fontWeight: FontWeight.bold), // Button text style
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corner radius
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30), // Button padding
                  ),
                  child: Text(
                    'PAY Rs.${totalBill.toStringAsFixed(2)}',
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
      MaterialPageRoute(builder: (context) => const SelectMachineForItems()),
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
                      _currentIndex = 2; // Set currentIndex to 0
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
  void _generateQRCode(String machineId, String subDocId, Map<String, String> itemQuantities) async {
    // Generate QR code with machineId, subDocId, and itemIds with quantities
    setState(() {
      _currentIndex=3;
    });
    String qrData = 'Machine ID: $machineId\n';
    qrData += 'Order ID: $subDocId\n';
    qrData += 'Items:\n';
    itemQuantities.forEach((itemId, quantity) {
      qrData += '  $itemId: $quantity\n';
    });

    // Save QR code data to SharedPreferences
    await _prefs.setString('qrData', qrData);

    showDialog(
      // ignore: use_build_context_synchronously
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
                  Navigator.pop(context); // Close the dialog
                  resetAndClearSelectedIds(machineId);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SelectMachineForItems()),
                  );
                },
                child: const Text('Close'),

              ),
            ],
          ),
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

  Future<void> resetAndClearSelectedIds(String machineId) async {
    // Reset selected item IDs and quantities
    for (String id in widget.selectedIds) {
      await _prefs.remove(id);
    }
    setState(() {
      itemQuantities.clear();
      totalBill = 0.0;
    });

    // Clear the selected IDs for the specified machine
    await _prefs.remove(machineId);
  }


}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    text = text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    var newText = '';
    for (var i = 0; i < text.length; i += 4) {
      if (i != 0) {
        newText += ' ';
      }
      if (i + 4 <= text.length) {
        newText += text.substring(i, i + 4);
      } else {
        newText += text.substring(i);
      }
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newText.length,
      ),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    text = text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    var newText = '';
    for (var i = 0; i < text.length; i++) {
      if (i == 2) {
        newText += '/';
      }
      newText += text[i];
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newText.length,
      ),
    );
  }
}
