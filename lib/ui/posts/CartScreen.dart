// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'cart_items.dart';
//
// class CartScreen extends StatefulWidget {
//   @override
//   _CartScreenState createState() => _CartScreenState();
// }
//
// class _CartScreenState extends State<CartScreen> {
//   final DatabaseReference _cartRef = FirebaseDatabase.instance.reference().child('cart');
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Cart'),
//         backgroundColor: Color(0xffffcc00),
//       ),
//       body: StreamBuilder(
//         stream: _cartRef.onValue,
//         builder: (context, snapshot) {
//           if (snapshot.hasData && snapshot.data.snapshot.value != null) {
//             Map<String, dynamic> cartData = snapshot.data.snapshot.value;
//             List<CartItem> cartItems = cartData.entries
//                 .map((entry) => CartItem.fromMap(entry.key, entry.value))
//                 .toList();
//
//             return ListView.builder(
//               itemCount: cartItems.length,
//               itemBuilder: (context, index) {
//                 CartItem cartItem = cartItems[index];
//                 return ListTile(
//                   title: Text(cartItem.productName),
//                   subtitle: Text('Price: \$${cartItem.price}'),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.remove),
//                         onPressed: () {
//                           removeFromCart(cartItem.id);
//                         },
//                       ),
//                       Text('${cartItem.quantity}'),
//                       IconButton(
//                         icon: Icon(Icons.add),
//                         onPressed: () {
//                           addToCart(cartItem.productName, cartItem.price);
//                         },
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           } else {
//             return Center(
//               child: Text('No items in the cart'),
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   void removeFromCart(String id) {
//     _cartRef.child(id).remove();
//   }
//
//   void addToCart(String productName, double price) {
//     final newCartItemRef = _cartRef.push();
//     newCartItemRef.set({
//       'productName': productName,
//       'price': price,
//       'quantity': 1,
//       // Add other fields as needed
//     });
//   }
// }
