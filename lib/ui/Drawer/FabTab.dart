// import 'package:flutter/material.dart';
// import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';
// import 'package:vending_app/ui/Pages/HomePage.dart';
// import 'package:vending_app/ui/Pages/MyCartPage.dart';
// import 'package:vending_app/ui/Pages/refferFriend.dart';
// import 'package:vending_app/ui/Pages/ProfilePage.dart';
// import 'package:vending_app/ui/posts/product_ui_widget.dart';
//
//
// class FabTabs extends StatefulWidget {
//   int selectedIndex = 0;
//   FabTabs({required this.selectedIndex});
//
//   @override
//   State<FabTabs> createState() => _FabTabsState();
// }
//
// class _FabTabsState extends State<FabTabs> {
//
//   int _currentIndex = 0;
//
//   void onItemTapped(int index) {
//     setState(() {
//       widget.selectedIndex = index;
//       _currentIndex = widget.selectedIndex;
//     });
//   }
//
//   @override
//   void initState() {
//     onItemTapped(widget.selectedIndex);
//     super.initState();
//   }
//
//
//
//   final List<Widget> pages = [
//     HomePage(),
//   //  selectMachineForItems(),
//
//     MyCartPage(),
//     OrderHistoryPage(),
//     ProfilePage(),
//   ];
//
//   final PageStorageBucket bucket = PageStorageBucket();
//
//   @override
//   Widget build(BuildContext context) {
//     Widget currentScreen = pages[_currentIndex]; // Use pages list here
//     return Scaffold(
//       body: PageStorage(
//         child: currentScreen,
//         bucket: bucket,
//       ),
//
//       bottomNavigationBar: BottomNavigationBar(
//       backgroundColor: Colors.white,
//       selectedItemColor: Colors.orangeAccent,
//       unselectedItemColor: Colors.black,
//       showUnselectedLabels: true,
//       onTap: onTapped,
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
//           label: "My Orders",
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person),
//           label: "Profile",
//         ),
//       ],
//     ),
//     );
//   }
//
//   void onTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }
// }