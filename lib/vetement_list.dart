import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'vetementDetailPage.dart';
import 'panier_page.dart';
import 'profile_page.dart';

class VetementListPage extends StatefulWidget {
  const VetementListPage({super.key});

  @override
  _VetementListPageState createState() => _VetementListPageState();
}

class _VetementListPageState extends State<VetementListPage> {
  int _selectedIndex = 0;

  Stream<QuerySnapshot> _getClothingStream() {
    return FirebaseFirestore.instance.collection('vetements').snapshots();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToDetail(DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VetementDetailPage(doc: doc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Scaffold(
        appBar: AppBar(
          title: const Text('Acheter des Vêtements'),
          backgroundColor: const Color(0xFF00afb9),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _getClothingStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            final clothingDocs = snapshot.data?.docs;

            if (clothingDocs == null || clothingDocs.isEmpty) {
              return const Center(child: Text("Aucun vêtement disponible."));
            }

            return ListView.builder(
              itemCount: clothingDocs.length,
              itemBuilder: (context, index) {
                final doc = clothingDocs[index];
                final data = doc.data() as Map<String, dynamic>;

                final base64String = data['image']?.split(',').last ?? '';
                final decodedImage = base64String.isNotEmpty ? base64Decode(base64String) : null;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (decodedImage != null)
                          Container(
                            height: 120, // Height of the image container
                            width: 120, // Set a fixed width for the image
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                decodedImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 120, // Height of the placeholder
                            width: 120, // Width of the placeholder
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Image non disponible",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          data['titre'] ?? 'Titre non disponible',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // Slightly smaller font size for the title
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['taille'] != null ? 'Taille: ${data['taille']}' : 'Taille non disponible',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['prix'] != null ? 'Prix: ${data['prix']} €' : 'Prix non disponible',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => _navigateToDetail(doc),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00afb9),
                              foregroundColor: Colors.white, // Set text color to white
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Détails'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      PanierPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Acheter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00afb9),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
