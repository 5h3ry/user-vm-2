
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_app/ui/MachineIntro/cart_page.dart';
import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';



class OrderPage extends StatefulWidget {
  final List<String> selectedIds;
  final String machineId;
  OrderPage({required this.selectedIds, required this.machineId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Future<List<Map<String, dynamic>>> _selectedItemsFuture;
  late SharedPreferences _prefs; // Add SharedPreferences instance
  final fireStore = FirebaseFirestore.instance.collection('Orders');
  final GlobalKey _globalKey = GlobalKey();
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderNameController = TextEditingController();




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
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }
  @override
  void dispose() {
    _animationController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
   // _animationController.dispose();
    super.dispose();
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

  void _showPaymentDoneAnimation() {
    if (_animationController.isAnimating || _animationController.isCompleted) {
      _animationController.reset();
    }

    _animationController.forward();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: ScaleTransition(
            scale: _animation,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 80.0, color: Colors.green),
                  SizedBox(height: 20),
                  Text(
                    'Payment Done',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
        _animationController.reset();
      }
      Navigator.of(context).pop(); // Close the modal
      addSubCollection();
    });

  }

  void _showPaymentForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (_, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the modal
                            },
                          ),
                          Text(
                            'Payment Form',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 40), // Placeholder for cross button alignment
                        ],
                      ),
                      SizedBox(height: 30.0),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _cardNumberController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Card Number',
                                labelStyle: TextStyle(color: Colors.white),
                                hintText: '1234 5678 9012 3456',
                                hintStyle: TextStyle(color: Colors.white38),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                filled: true,
                                fillColor: Colors.black54,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(16),
                                _CardNumberInputFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your card number';
                                } else if (value.replaceAll(' ', '').length != 16) {
                                  return 'Card number must be 16 digits';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    controller: _expiryDateController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Expiry Date',
                                      labelStyle: TextStyle(color: Colors.white),
                                      hintText: 'MM/YY',
                                      hintStyle: TextStyle(color: Colors.white38),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: Colors.black54,
                                    ),
                                    keyboardType: TextInputType.datetime,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      _ExpiryDateInputFormatter(),
                                      LengthLimitingTextInputFormatter(5),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter the expiry date';
                                      } else if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                                        return 'Enter a valid expiry date';
                                      }

                                      var parts = value.split('/');
                                      var month = int.tryParse(parts[0]);
                                      var year = int.tryParse(parts[1]);

                                      if (month == null || year == null) {
                                        return 'Invalid expiry date format';
                                      }

                                      if (month < 1 || month > 12) {
                                        return 'Invalid';
                                      }

                                      if (year <= 23) {
                                        return 'Invalid';
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: TextFormField(
                                    controller: _cvvController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'CVV',
                                      labelStyle: TextStyle(color: Colors.white),
                                      hintText: '123',
                                      hintStyle: TextStyle(color: Colors.white38),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: Colors.black54,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter the CVV';
                                      } else if (value.length != 3) {
                                        return 'CVV must be 3 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _cardHolderNameController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Card Holder Name',
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                filled: true,
                                fillColor: Colors.black54,
                              ),
                              keyboardType: TextInputType.name,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the card holder\'s name';
                                } else if (!RegExp(r'^[a-zA-Z\s]{3,24}$').hasMatch(value)) {
                                  return 'Invalid Name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 30.0),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  if (_animationController.isAnimating || _animationController.isCompleted) {
                                    _animationController.reset();
                                  }
                                  _showPaymentDoneAnimation();
                                }
                              },
                              child: Text(
                                'Pay Rs.${totalBill.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 18.0, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.0),
                    ],
                  ),

                ),
              );
            },
          ),
        );
      },
    );
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
                  //  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>PaymentPage() ),);

                    _showPaymentForm(context);

                   // addSubCollection(); // Call addSubCollection to handle everything including QR code generation
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
                    'PAY NOW',
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
                      _currentIndex = 2; // Set currentIndex to 0
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
                  Navigator.pop(context); // Close the dialog
                  resetAndClearSelectedIds(machineId);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SelectMachineForItems()),
                  );
                },
                child: Text('Close'),

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
