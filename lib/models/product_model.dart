import 'dart:convert';

class ProductModel {
  //Membuat Variabel untuk menyimpan data produk
  final String name;
  final String description;
  final int price;

  //constructor untuk menginisialisasi variabel
  ProductModel({
    required this.name,
    required this.description,
    required this.price,
  });

  //konversi objek ke map
  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'price': price};
  }

  //konversi map ke objek
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
    );
  }

  //konversi objek ke json sring
  String toJson() => jsonEncode(toMap());

  //konversi json string ke objek
  factory ProductModel.fromJson(String source) {
    return ProductModel.fromMap(jsonDecode(source));
  }
}
