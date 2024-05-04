// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:food_app/models/user_model.dart';
//
// class UserProvider with ChangeNotifier {
//   final DatabaseReference _databaseReference =
//   FirebaseDatabase.instance.reference();
//
//   void addUserData({
//     User currentUser,
//     String userName,
//     String userImage,
//     String userEmail,
//   }) async {
//     await _databaseReference.child('usersData').child(currentUser.uid).set({
//       "userName": userName,
//       "userEmail": userEmail,
//       "userImage": userImage,
//       "userUid": currentUser.uid,
//     });
//   }
//
//   UserModel currentData;
//
//   void getUserData() async {
//     UserModel userModel;
//     var snapshot = await _databaseReference
//         .child('usersData')
//         .child(FirebaseAuth.instance.currentUser.uid)
//         .once();
//     if (snapshot.value != null) {
//       userModel = UserModel(
//         userEmail: snapshot.value["userEmail"],
//         userImage: snapshot.value["userImage"],
//         userName: snapshot.value["userName"],
//         userUid: snapshot.value["userUid"],
//       );
//       currentData = userModel;
//       notifyListeners();
//     }
//   }
//
//   UserModel get currentUserData {
//     return currentData;
//   }
// }
