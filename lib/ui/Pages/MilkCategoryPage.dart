// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:badges/badges.dart' as badges;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:vending_app/firebase_services/CartState.dart';
// import 'package:vending_app/ui/Drawer/FabTab.dart';
// import 'package:vending_app/ui/Pages/MyCartPage.dart';
//
// int count = 0;
// GlobalKey<badges.BadgeState> badgeKey = GlobalKey<badges.BadgeState>();
// final counterProvider = StateProvider<int>((ref) => 0);
//
// class MilkCategoryPage extends ConsumerStatefulWidget {
//   final String title;
//   final String catImage;
//   final String tag;
//
//   const MilkCategoryPage({
//     Key? key,
//     required this.title,
//     required this.catImage,
//     required this.tag,
//   }) : super(key: key);
//
//   @override
//   ConsumerState<MilkCategoryPage> createState() => _CategoriespageState();
// }
//
// class _CategoriespageState extends ConsumerState<MilkCategoryPage> {
//   final refa = FirebaseDatabase.instance
//       .reference()
//       .child('Products')
//       .orderByChild('pid')
//       .equalTo('p0');
//
//   @override
//   Widget build(BuildContext context) {
//     final count1 = ref.watch(counterProvider);
//     return Scaffold(
//       body: NestedScrollView(
//         headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//           return <Widget>[
//             SliverAppBar(
//               leading: GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Icon(
//                   Icons.arrow_back,
//                   color: Colors.white,
//                 ),
//               ),
//               title: Text(
//                 widget.title,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 30,
//                 ),
//               ),
//               backgroundColor: Colors.white,
//               expandedHeight: 140,
//               flexibleSpace: FlexibleSpaceBar(
//                 background: Container(
//                   height: 140,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage(
//                         widget.catImage,
//                       ),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   child: Container(
//                     padding: EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.bottomRight,
//                         colors: [
//                           Colors.black.withOpacity(.0),
//                           Colors.black.withOpacity(.6),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               actions: [
//                 Center(
//                   child: badges.Badge(
//                     key: badgeKey,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => FabTabs(selectedIndex: 1),
//                         ),
//                       );
//                     },
//                     badgeContent: Text(
//                       count1.toString(),
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     child: Icon(
//                       Icons.shopping_bag_outlined,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 20,
//                 )
//               ],
//             )
//           ];
//         },
//         body: Column(
//           children: [
//             Expanded(
//               child: FirebaseAnimatedList(
//                 defaultChild: Text('loading'),
//                 query: refa,
//                 itemBuilder: (context, snapshot, animation, index) {
//                   // Extract quantity from the snapshot
//                   int? quantity = (snapshot.child('quantity').value ?? 1) as int?;
//                   return ProductWidget(
//                     snapshot: snapshot,
//                     quantity: quantity!,
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ProductWidget extends ConsumerStatefulWidget {
//   final DataSnapshot snapshot;
//   final int quantity;
//
//   ProductWidget({required this.snapshot, required this.quantity});
//
//   @override
//   ConsumerState<ProductWidget> createState() => _ProductWidgetState();
// }
//
// class _ProductWidgetState extends ConsumerState<ProductWidget> {
//   late int _currentQuantity;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentQuantity = widget.quantity;
//   }
//
//   // Function to update quantity in the database
//   void _updateQuantityInDatabase(String pid, int newQuantity) {
//     // Invert the newQuantity value when updating the database
//     FirebaseDatabase.instance
//         .reference()
//         .child('Products')
//         .child(pid)
//         .update({'quantity': 10 - newQuantity});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ProductsUI(
//       refa: ref,
//       category: widget.snapshot.child('category').value.toString(),
//       pName: widget.snapshot.child('pName').value.toString(),
//       price: widget.snapshot.child('price').value.toString(),
//       pid: widget.snapshot.child('pid').value.toString(),
//       image: widget.snapshot.child('image').value.toString(),
//       type: widget.snapshot.child('type').value.toString(),
//       description: widget.snapshot.child('description').value.toString(),
//       quantity: _currentQuantity,
//       onPlusTap: () {
//         // Handle plus button tap
//         if (_currentQuantity < 10) {
//           // Update quantity in UI and database
//           setState(() {
//             _currentQuantity++;
//           });
//           _updateQuantityInDatabase(
//               widget.snapshot.child('pid').value.toString(), _currentQuantity);
//         }
//       },
//       onMinusTap: () {
//         // Handle minus button tap
//         if (_currentQuantity > 1) {
//           // Update quantity in UI and database
//           setState(() {
//             _currentQuantity--;
//           });
//           _updateQuantityInDatabase(
//               widget.snapshot.child('pid').value.toString(), _currentQuantity);
//         }
//       },
//     );
//   }
// }
//
// class ProductsUI extends StatefulWidget {
//   final WidgetRef refa;
//   final String category;
//   final String pName;
//   final String price;
//   final String pid;
//   final String image;
//   final String type;
//   final String description;
//   final int quantity;
//   final VoidCallback onPlusTap;
//   final VoidCallback onMinusTap;
//
//   ProductsUI({
//     required this.refa,
//     required this.category,
//     required this.pName,
//     required this.price,
//     required this.pid,
//     required this.image,
//     required this.type,
//     required this.description,
//     required this.quantity,
//     required this.onPlusTap,
//     required this.onMinusTap,
//   });
//
//   @override
//   _ProductsUIState createState() => _ProductsUIState();
// }
//
// class _ProductsUIState extends State<ProductsUI> {
//   bool _itemAddedToCart = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // Handle the onTap event
//       },
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//             child: Stack(
//               children: [
//                 Container(
//                   height: 250,
//                   width: double.infinity,
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Image.network(
//                       widget.image,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 RatingBar(
//                   initialRating: 4,
//                   direction: Axis.horizontal,
//                   allowHalfRating: true,
//                   itemCount: 5,
//                   itemSize: 20,
//                   ratingWidget: RatingWidget(
//                     full: Icon(Icons.star, color: Colors.amber),
//                     half: Icon(Icons.star_half, color: Colors.amber),
//                     empty: Icon(Icons.star_border, color: Colors.amber),
//                   ),
//                   itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                   onRatingUpdate: (index) {
//                     // Handle rating updates if needed
//                   },
//                 ),
//
//                 Text(
//                   widget.price,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 22,
//                     color: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.pName,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 28,
//                     color: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               widget.description,
//               style: TextStyle(
//                 fontSize: 16,
//               ),
//               textAlign: TextAlign.justify,
//             ),
//           ),
//           SizedBox(height: 10),
//           Container(
//             color: Color(0xD5D0D0FF),
//             height: 70,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(left: 50, bottom: 5),
//                   child: Builder(builder: (context) {
//                     return ElevatedButton(
//                       onPressed: () {
//                         if (!_itemAddedToCart) {
//                           CartItem cartItem = CartItem(
//                             productName: widget.pName,
//                             quantity: widget.quantity,
//                             image: widget.image,
//                             price: widget.price,
//                           );
//
//                           widget.refa.read(cartstateprovider.notifier).addToCart(cartItem);
//
//                           widget.refa.read(counterProvider.notifier).state++;
//                           setState(() {
//                             count++;
//                             _itemAddedToCart = true;
//                           });
//
//
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         primary: Colors.red, // Change color as needed
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                       ),
//                       child: Text(
//                         'Add to Cart',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//                 SizedBox(width: 15),
//                 Padding(
//                   padding: EdgeInsets.only(left: 40, bottom: 5),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Handle Buy Now logic
//                     },
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.red, // Change color as needed
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                     child: Text(
//                       'Buy Now',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
