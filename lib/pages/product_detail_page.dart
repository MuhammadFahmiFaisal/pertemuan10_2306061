import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'dart:convert';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            product.image.isNotEmpty
                ? Image.memory(
                    base64Decode(product.image),
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 120, color: Colors.grey),
            Text('Rp ${product.price}'),
            const SizedBox(height: 10),
            Text(product.description),
          ],
        ),
      ),
    );
  }
}
