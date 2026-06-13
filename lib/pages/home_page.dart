import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import '../models/product_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "";

  //variabel utama untuk menyimpan data produk
  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    getUser();
    loadProducts();
  }

  //fungsi untuk memuat data produk dari shared preferences
  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> productList = prefs.getStringList("products") ?? [];
    setState(() {
      products = productList
          .map((item) => ProductModel.fromJson(item))
          .toList();
    });
  }

  //fungsi untuk menyimpan data produk ke shared preferences
  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = products.map((item) => item.toJson()).toList();
    await prefs.setStringList("products", productList);
  }

  //fungsi untuk menambah produk baru
  Future<void> addProduct(ProductModel product) async {
    setState(() {
      products.add(product);
    });
    await saveProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil ditambahkan!")),
    );
  }

  //fungsi untuk edit produk yang sudah ada
  Future<void> updateProduct(int index, ProductModel product) async {
    setState(() {
      products[index] = product;
    });
    await saveProducts();
  }

  //fungsi untuk menghapus produk
  Future<void> deleteProduct(int index) async {
    setState(() {
      products.removeAt(index);
    });
    await saveProducts();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Produk berhasil dihapus!")));
  }

  //metode showForm untuk menampilkan
  void showForm({ProductModel? product, int? index}) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController(
      text: product?.name ?? "",
    );
    TextEditingController descriptionController = TextEditingController(
      text: product?.description ?? "",
    );
    TextEditingController priceController = TextEditingController(
      text: product?.price.toString() ?? "",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? "Tambah Produk" : "Edit Produk"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama Produk"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi Produk"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Harga Produk"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga produk tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Harga harus berupa angka yang valid';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newProduct = ProductModel(
                  name: nameController.text,
                  description: descriptionController.text,
                  price: int.parse(priceController.text),
                );

                if (product == null) {
                  addProduct(newProduct);
                } else {
                  updateProduct(index!, newProduct);
                }
                Navigator.pop(context);
              }
            },
            icon: Icon(product == null ? Icons.save : Icons.update),
            label: Text(product == null ? "Simpan" : "Update"),
          ),
        ],
      ),
    );
  }

  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "";
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage("assets/fahmi.jpg"),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Hai, Selamat Datang!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.verified, color: Colors.blue[800], size: 20),
                      ],
                    ),
                    InkWell(
                      onTap: logout,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.logout,
                          size: 28,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: products.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada produk, silahkan tambah produk baru!",
                        ),
                      )
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(15),
                              title: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.description),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Rp ${product.price}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              leading: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => showForm(
                                  product: products[index],
                                  index: index,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteProduct(index),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
