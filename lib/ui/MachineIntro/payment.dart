// ;
//
// class PaymentPage extends StatefulWidget {
//   const PaymentPage({Key? key}) : super(key: key);
//
//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }
//
// class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
//
//
//   @override
//   void initState() {
//     super.initState();
//
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text('Main Page'),
//         backgroundColor: Colors.teal,
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//           },
//           child: Text(
//             'Open Payment Form',
//             style: TextStyle(fontSize: 18.0, color: Colors.white),
//           ),
//           style: ElevatedButton.styleFrom(
//             padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
//             backgroundColor: Colors.teal,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//           ),
//         ),
//       ),
//       backgroundColor: Colors.black87,
//     );
//   }
// }
//
// void main() {
//   runApp(MaterialApp(
//     home: PaymentPage(),
//     theme: ThemeData.dark().copyWith(
//       primaryColor: Colors.deepPurple,
//       colorScheme: ColorScheme.dark(
//         primary: Colors.deepPurple,
//         secondary: Colors.purpleAccent,
//       ),
//       textTheme: const TextTheme(
//         bodyMedium: TextStyle(color: Colors.white),
//       ),
//     ),
//   ));
// }
//
