import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import '../models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/product_card.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _formKey = GlobalKey<FormState>();
  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = prefs.getStringList('products') ?? [];
    setState(() {
      products = productList
          .map((item) => ProductModel.fromJson(item))
          .toList();
    });
  }

  // Method untuk menyimpan data produk ke SharedPreferences
  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = products.map((item) => item.toJson()).toList();
    await prefs.setStringList('products', productList);
  }

  // Method untuk menambahkan, mengupdate, dan menghapus produk
  Future<void> addProduct(ProductModel product) async {
    setState(() {
      products.add(product);
    });
    await saveProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil ditambahkan!")),
    );
  }

  // Method untuk mengupdate produk berdasarkan index
  Future<void> updateProduct(int index, ProductModel product) async {
    setState(() {
      products[index] = product;
    });
    await saveProducts();
  }

  // Method untuk menghapus produk berdasarkan index
  Future<void> deleteProduct(int index) async {
    setState(() {
      products.removeAt(index);
    });
    await saveProducts();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Product berhasil dihapus!")));
  }

  //Method untuk convert gambar ke base64
  Future<String> convertImageToBase64(XFile image) async {
    Uint8List bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  void showForm({ProductModel? product, int? index}) {
    TextEditingController nameController = TextEditingController(
      text: product?.name ?? "",
    );
    TextEditingController descriptionController = TextEditingController(
      text: product?.description ?? "",
    );
    TextEditingController priceController = TextEditingController(
      text: product?.price.toString() ?? "",
    );
    TextEditingController imageController = TextEditingController(
      text: product?.image ?? "",
    );

    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    //methode untuk memilih gambar dari galeri
    Future<void> pickImage(StateSetter setDialogState) async {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setDialogState(() {
          selectedImage = image;
          imageController.text = image.path;
        });
      }
      print(selectedImage?.path);
    }

    Widget previewImage() {
      // Jika user memilih gambar baru
      if (selectedImage != null) {
        return FutureBuilder<Uint8List>(
          future: selectedImage!.readAsBytes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return Image.memory(
              snapshot.data!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            );
          },
        );
      }

      // Jika mode edit dan sudah ada gambar produk
      if (product?.image.isNotEmpty ?? false) {
        return Image.memory(
          base64Decode(product!.image),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        );
      }

      // Jika tidak ada gambar
      return const SizedBox.shrink();
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(product == null ? "Tambah Produk" : "Edit Produk"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Nama"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: "Deskripsi"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: "Harga"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harga harus berupa angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => pickImage(setDialogState),
                    icon: const Icon(Icons.image),
                    label: const Text("Pilih Gambar"),
                  ),
                  const SizedBox(height: 10),
                  previewImage(),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  String imageBase64 = product?.image ?? "";
                  if (selectedImage != null) {
                    imageBase64 = await convertImageToBase64(selectedImage!);
                  }

                  final price = int.parse(priceController.text);
                  final newProduct = ProductModel(
                    name: nameController.text,
                    description: descriptionController.text,
                    price: price,
                    image: imageBase64,
                  );

                  if (product == null) {
                    addProduct(newProduct);
                  } else {
                    updateProduct(index!, newProduct);
                  }
                  Navigator.pop(context);
                },
                child: Text(product == null ? "Simpan" : "Perbarui"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produk", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text("Belum ada produk"))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onDelete: () => deleteProduct(index),
                          onEdit: () =>
                              showForm(product: product, index: index),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(product: product),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
