import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'dart:convert';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        onTap: onTap,
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            product.image.isNotEmpty
                ? Image.memory(
                    base64Decode(product.image),
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 120, color: Colors.grey),
            Text("Rp ${product.price}"),
            const SizedBox(height: 5),
            Text(product.description),
          ],
        ),
        leading: onEdit != null
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: onEdit,
              )
            : null,
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
