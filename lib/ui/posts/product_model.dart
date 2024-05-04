class ProductModel {
  final String id;
  final String title;
  final String image;
  final String price;
  int quantity;

  ProductModel({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.quantity = 1,
  });
}
