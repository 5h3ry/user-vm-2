// import 'package:flutter/material.dart';
// import 'package:vending_app/ui/Drawer/drawer_side.dart';
// import 'MilkCategoryPage.dart';
// import 'ChocolateCategoryPage.dart';
// import 'BiscuitCategoryPage.dart';
// import 'package:carousel_slider/carousel_slider.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white70,
//       drawer: DrawerSide(),
//       body: NestedScrollView(
//         headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//           return <Widget>[
//             SliverAppBar(
//               backgroundColor: Color(0xffffcc00),
//               automaticallyImplyLeading: false,
//               title: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   IconButton(
//                     icon: Icon(Icons.menu),
//                     onPressed: () {
//                       Scaffold.of(context).openDrawer();
//                     },
//                   ),
//                 ],
//               ),
//               expandedHeight: 150,
//               flexibleSpace: FlexibleSpaceBar(
//                 background: SizedBox(
//                   height: 150,
//                   width: double.infinity,
//                   child: CarouselSlider(
//                     options: CarouselOptions(
//                       autoPlay: true,
//                     ),
//                     items: [
//                       Image.asset('assets/biscuitbanner.png'),
//                       Image.asset('assets/milkbanner.png'),
//                       Image.asset('assets/chocobanner.png'),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           ];
//         },
//         body: SingleChildScrollView(
//           child: Center(
//             child: Column(
//               children: <Widget>[
//                 makeCategory(
//                   catImage: 'assets/biscuiit.png',
//                   title: 'Biscuit',
//                   tag: 'Snack',
//                   color: Colors.blue,
//                 ),
//                 makeCategory(
//                   catImage: 'assets/choco.png',
//                   title: 'Chocolate',
//                   tag: 'Snack',
//                   color: Colors.purple,
//                 ),
//                 makeCategory(
//                   catImage: 'assets/milkolpers.png',
//                   title: 'Milk',
//                   tag: 'Drink',
//                   color: Colors.red,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget makeCategory({required catImage, required title, required tag, required color}) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Card(
//         elevation: 3,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: InkWell(
//           onTap: () {
//             // Define the category-specific page to navigate to
//             Widget? categoryPage;
//
//             // Choose the category page based on the clicked category
//             if (title == 'Milk') {
//               categoryPage = MilkCategoryPage(
//                 title: title,
//                 catImage: catImage,
//                 tag: tag,
//               );
//             } else if (title == 'Chocolate') {
//               categoryPage = ChocolateCategoryPage(
//                 title: title,
//                 catImage: catImage,
//                 tag: tag,
//               );
//             } else if (title == 'Biscuit') {
//               categoryPage = BiscuitCategoryPage(
//                 title: title,
//                 catImage: catImage,
//                 tag: tag,
//               );
//             }
//
//             // Navigate to the selected category page
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => categoryPage ?? Container()), // Use Container() as a default value
//             );
//           },
//
//           child: Column(
//             children: <Widget>[
//               Container(
//                 height: 240,
//                 width: 310,
//                 decoration: BoxDecoration(
//                   color: color,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//                   image: DecorationImage(
//                     image: AssetImage(catImage),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.all(8),
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }