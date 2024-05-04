// // product_widgets.dart
//
// import 'package:flutter/material.dart';
//
// Widget productsUI(
//     String category,
//     String pName,
//     String price,
//     String pid,
//     String image,
//     String type,
//     int quantity,
//     VoidCallback onPlusTap,
//     VoidCallback onMinusTap,
//     ) {
//   return GestureDetector(
//     onTap: () {
//       // Handle the onTap event
//     },
//     child: Padding(
//       padding: EdgeInsets.all(8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//             child: Container(
//               height: 100,
//               width: 110,
//               child: Image.network(
//                 image,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   pName,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   "Price: $price",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Quantity: $quantity",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                     ),
//                     Container(
//                       width: 80,
//                       padding: EdgeInsets.all(5),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           GestureDetector(
//                             onTap: onMinusTap,
//                             child: Icon(
//                               Icons.remove,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),
//                           Text(
//                             quantity.toString(),
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: onPlusTap,
//                             child: Icon(
//                               Icons.add,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
