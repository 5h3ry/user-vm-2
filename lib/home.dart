import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_app/payment.dart';
import 'package:vending_app/ui/MachineIntro/cart_page.dart';
import 'package:vending_app/ui/MachineIntro/orders.dart';
import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';


import 'constants.dart';

class HomePage extends StatefulWidget {
  final List<String> selectedIds;
  final String machineId;
  final double totalBill;
  const HomePage({super.key, required this.selectedIds, required this.machineId,required this.totalBill});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formkey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Future<List<Map<String, dynamic>>> _selectedItemsFuture;
  late SharedPreferences _prefs; // Add SharedPreferences instance
  final fireStore = FirebaseFirestore.instance.collection('Orders');
  bool loading = false;

  String selectedCurrency = 'USD';
  bool hasDonated = false;
  late int totalBill = widget.totalBill.toInt(); // Predefined donation amount
  Future<void> initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }
  Map<String, String> itemQuantities = {};
  //double totalBill = 0.0;
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



  Future<void> initPaymentSheet() async {
    try {
      // 1. create payment intent on the client side by calling stripe api
      final data = await createPaymentIntent(
        amount: (totalBill * 100).toString(),
        currency: selectedCurrency,
        name: 'Sheharyar',
        address: '123 main st',
        pin: '50000',
        city: 'sarai alamgir',
        state: 'pk',
        country: 'Pakistan',
      );

      // 2. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Test Merchant',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }


  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //     backgroundColor: Color(0xFFFFCC00), // Specify your color here
  //     title: Text('Home Page'),
  //   ),
  //     body: SingleChildScrollView(
  //       child: Column(
  //         children: [
  //           hasDonated
  //               ? Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //
  //
  //                 SizedBox(height: 16),
  //                 SizedBox(
  //                   height: 50,
  //                   width: double.infinity,
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.blueAccent.shade400),
  //                     child: Text(
  //                       "Donate again",
  //                       style: TextStyle(color: Colors.white, fontSize: 16),
  //                     ),
  //                     onPressed: () {
  //                       setState(() {
  //                         hasDonated = false;
  //                       });
  //                     },
  //                   ),
  //                 ),
  //
  //               ],
  //             ),
  //           )
  //               : Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   "Pay your bill by using any debit/credit card",
  //                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
  //                 ),
  //                 SizedBox(height: 6),
  //                 SizedBox(
  //                   height: 50,
  //                   width: double.infinity,
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.blueAccent.shade400),
  //                     child: Text(
  //                       "Proceed to Pay \$$totalBill",
  //                       style: TextStyle(color: Colors.white, fontSize: 16),
  //                     ),
  //                     onPressed: () async {
  //                       await initPaymentSheet();
  //
  //                       try {
  //                         await Stripe.instance.presentPaymentSheet();
  //
  //                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                           content: Text(
  //                             "Payment Done",
  //                             style: TextStyle(color: Colors.white),
  //                           ),
  //                           backgroundColor: Colors.green,
  //                         ));
  //
  //                         setState(() {
  //                           hasDonated = true;
  //                         });
  //                       } catch (e) {
  //                         print("payment sheet failed");
  //                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                           content: Text(
  //                             "Payment Failed",
  //                             style: TextStyle(color: Colors.white),
  //                           ),
  //                           backgroundColor: Colors.redAccent,
  //                         ));
  //                       }
  //                     },
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     bottomNavigationBar: BottomNavigationBar(
  //       backgroundColor: Colors.white,
  //       selectedItemColor: Colors.orangeAccent,
  //       unselectedItemColor: Colors.black,
  //       showUnselectedLabels: true,
  //       onTap: onTabTapped,
  //       currentIndex: _currentIndex,
  //       items: const [
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.home),
  //           label: "Home",
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.shopping_cart),
  //           label: "My Cart",
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.list),
  //           label: "Order Summary",
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.backpack),
  //           label: "Last Order",
  //         ),
  //       ],
  //     ),    );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFCC00), // Specify your color here
        title: Text('Payment Gateway'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [Image(
            image: AssetImage("assets/6081538.jpg"),
            height: 450,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
            hasDonated
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // UI for donation confirmation or any other relevant content
                ],
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   "Pay your bill by using any debit/credit card",
                  //   style: TextStyle(
                  //     fontSize: 28,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  SizedBox(height: 6),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        "Proceed to Pay \$$totalBill",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () async {
                        await initPaymentSheet();

                        try {
                          await Stripe.instance.presentPaymentSheet();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Payment Done",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );

                          setState(() {
                            hasDonated = true;
                          });

                          // Add the order collection and QR code generation here
                          addSubCollection();
                        } catch (e) {
                          print("payment sheet failed");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Payment Failed",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                    ),
                  )
                ],
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
      //totalBill = 0.0;
    });

    // Clear the selected IDs for the specified machine
    await _prefs.remove(machineId);
  }


}
