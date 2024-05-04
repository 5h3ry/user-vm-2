// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:vending_app/firebase_services/CartState.dart';
// import 'package:vending_app/ui/Drawer/FabTab.dart';
// import 'package:vending_app/ui/Drawer/drawer_side.dart';
// import 'package:vending_app/ui/Pages/OrderHistoryPage.dart';
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
// class MyCartPage extends ConsumerStatefulWidget {
//   const MyCartPage({Key? key}) : super(key: key);
//
//   @override
//   ConsumerState<MyCartPage> createState() => _MyCartPageState();
// }
//
// class _MyCartPageState extends ConsumerState<MyCartPage> {
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
//       drawer: DrawerSide(),
//       appBar: AppBar(
//         backgroundColor: Color(0xffffcc00),
//         title: Text('My Cart'),
//       ),
//       body: ListView.builder(
//         itemCount: cartItems.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             contentPadding: EdgeInsets.all(10),
//             leading: ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: Image.network(
//                 cartItems[index].image,
//                 width: 80,
//                 height: 60,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   cartItems[index].productName,
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                 ),
//                 Text('Price: ${cartItems[index].price}'),
//                 Text('Quantity: ${cartItems[index].quantity}'),
//               ],
//             ),
//             trailing: Container(
//               width: 90,
//               padding: EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Icon(
//                     CupertinoIcons.minus,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                   Text(
//                     "1",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Icon(
//                     CupertinoIcons.plus,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
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
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
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
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => FabTabs(selectedIndex: 2)));
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
//                     'CHECKOUT',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }
