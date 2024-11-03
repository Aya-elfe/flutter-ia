import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class PanierPage extends StatefulWidget {
  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  List<DocumentSnapshot> _cartItems = [];
  double _total = 0.0;
  bool _isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('panier').get();
      setState(() {
        _cartItems = snapshot.docs;
        _total = _calculateTotal(); // Calculate total after fetching items
        _isLoading = false; // End loading
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // End loading in case of error
      });
      print("Error fetching cart items: $e");
    }
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var item in _cartItems) {
      var price = item['prix'];
      if (price is String) {
        total += double.tryParse(price) ?? 0.0; // Use tryParse to safely convert
      } else if (price is num) {
        total += price; // Directly add if it's already a number
      }
    }
    return total;
  }

  Future<void> _removeItem(DocumentSnapshot item) async {
    try {
      await FirebaseFirestore.instance.collection('panier').doc(item.id).delete();
      setState(() {
        _cartItems.remove(item);
        _total = _calculateTotal(); // Update total after removal
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item['titre']} retiré du panier')),
      );
    } catch (e) {
      print("Error removing item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        backgroundColor: const Color(0xFF00AFB9), // Use your primary color here
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading indicator
            : _cartItems.isEmpty
                ? Center(
                    child: Text(
                      'Votre panier est vide.',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index].data() as Map<String, dynamic>;
                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Rounded corners
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: item['image'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10), // Rounded image
                                        child: Image.memory(
                                          base64Decode(item['image'].split(',').last),
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                title: Text(
                                  item['titre'] ?? 'Titre non disponible',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF00AFB9), // Match title color with the primary color
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5), // Spacing
                                    Text('Taille: ${item['taille'] ?? 'Non disponible'}'),
                                    Text('Prix: ${item['prix'] ?? 'Non disponible'} €', style: TextStyle(color: Colors.teal[800])),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.clear, color: Colors.red),
                                  onPressed: () => _removeItem(_cartItems[index]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Display total
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Total: $_total €',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF00afb9)),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
