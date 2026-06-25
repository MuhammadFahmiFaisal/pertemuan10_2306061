import 'dart:convert';

class ProductModel {
  // Membuat variable untuk menyimpan data produk
  final String name;
  final String description;
  final int price;

  // Contructor untuk menginisialisasi data produk
  ProductModel({
    required this.name,
    required this.description,
    required this.price,
  });

  // Method untuk mengubah data produk menjadi JSON
  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'price': price};
  }

  // Factory method untuk membuat instance ProductModel dari Map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toInt() ?? 0,
    );
  }

  // Method untuk mengubah data produk menjadi JSON string
  String toJson() => jsonEncode(toMap());

  // Factory method untuk membuat instance ProductModel dari JSON string
  factory ProductModel.fromJson(String source) {
    return ProductModel.fromMap(jsonDecode(source));
  }
}
