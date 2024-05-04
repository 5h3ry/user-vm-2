import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'product_model.dart';

class ProductService {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  Stream<List<ProductModel>> getProducts(List<String> productIds) {
    StreamController<List<ProductModel>> controller = StreamController();

    List<ProductModel> products = [];

    for (String productId in productIds) {
      _database.child('Products').child(productId).onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot != null && snapshot.value != null) {
          Map<String, dynamic> productData = snapshot.value as Map<String, dynamic>;
          ProductModel product = ProductModel(
            id: productId,
            title: productData['pName'],
            image: productData['image'],
            price: productData['price'],
            quantity: 1,
          );

          products.add(product);
          controller.add(products); // Add updated list to the stream
        }
      });
    }

    return controller.stream;
  }
}
