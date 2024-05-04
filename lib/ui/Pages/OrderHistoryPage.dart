// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:vending_app/firebase_services/CartState.dart';
// import 'package:vending_app/ui/Drawer/FabTab.dart';
// import 'package:vending_app/ui/Drawer/drawer_side.dart';
// import 'package:vending_app/ui/Pages/OrderHistoryPage.dart';
// import 'package:vending_app/ui/Pages/PaymentPage.dart';
//
// class CartItem {
//   final String productName;
//   final int quantity;
//   final String image;
//   final String price;
//
//   CartItem({
//     required this.productName,
//     required this.quantity,
//     required this.image,
//     required this.price,
//   });
// }
//
// class OrderHistoryPage extends ConsumerStatefulWidget {
//   const OrderHistoryPage({Key? key}) : super(key: key);
//
//   @override
//   ConsumerState<OrderHistoryPage> createState() => OrderHistoryPageState();
// }
//
// class OrderHistoryPageState extends ConsumerState<OrderHistoryPage> {
//   @override
//   Widget build(BuildContext context) {
//     final cartItems = ref.watch(cartstateprovider);
//
//     // Calculate total bill
//     double totalBill = 0;
//     for (var item in cartItems) {
//       totalBill += double.parse(item.price);
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => FabTabs(selectedIndex: 1)));
//           },
//           child: Icon(
//             Icons.arrow_back,
//             color: Colors.black,
//           ),
//         ),
//         backgroundColor: Color(0xffffcc00),
//         title: Text('My Orders'),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Center(
//               child: Text(
//                 'Order Summary',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: cartItems.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   contentPadding: EdgeInsets.all(10),
//                   title: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Product Name: ${cartItems[index].productName}',
//                       ),
//                       Text('Price: ${cartItems[index].price}'),
//                       Text('Quantity: 1'),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             color: Colors.grey[200],
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Total Bill:',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                 ),
//                 Text(
//                   '\$$totalBill',
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: Colors.red),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 10),
//           Align(
//             alignment: Alignment.bottomRight,
//             child: Padding(
//               padding: const EdgeInsets.only(right: 10.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage()));
//                 },
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.red,
//                   textStyle: TextStyle(fontWeight: FontWeight.bold),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10), // Set to zero for a rectangle
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust as needed
//                   child: Text(
//                     'Place Order',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//
//           SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }
