// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
//
// class QRCodeGenerator extends StatelessWidget {
//
//    QRCodeGenerator({
//     Key? key,
//     required this.selectedIds,
//     required this.machineId,
//    // required this.totalBill,
//   }) : super(key: key);
//
//   final List<String> selectedIds;
//   final String machineId;
//  // double totalBill;
//   @override
//   Widget build(BuildContext context) {
//    // String data = 'machineId: $machineId\nselectedIds: ${selectedIds.join(',')}\ntotalBill: $totalBill';
//
//     String data = 'machineId: $machineId\nselectedIds: ${selectedIds.join(',')}';
//    // String data = selectedIds.join(', ');
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('QR'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             QrImageView(
//               data: data,
//               version: QrVersions.auto,
//               gapless: false,
//               size: 320,
//             )
//           ],
//         )
//
//       ),
//     );
//   }
// }
