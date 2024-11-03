import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'panier_page.dart';

class VetementDetailPage extends StatelessWidget {
  final DocumentSnapshot doc;

  const VetementDetailPage({required this.doc, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;

    // Decode the Base64 image
    final base64String = data['image'].split(',').last;
    final decodedImage = base64Decode(base64String);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          data['titre'] ?? 'Détail du vêtement',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00afb9),
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 350),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.memory(
                    decodedImage,
                    fit: BoxFit.contain, // Ensure the entire image is visible
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: Text(
                data['titre'] ?? 'Titre non disponible',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00afb9),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            _buildDetailText('Catégorie', data['categorie']),
            _buildDetailText('Taille', data['taille']),
            _buildDetailText('Marque', data['marque']),
            _buildDetailText(
              'Prix',
              data['prix'] != null ? '${data['prix']} €' : 'Non disponible',
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AFB9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  ),
                  child: const Text('Retour', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Ajout du vêtement au panier: ${data['titre']}');

                    FirebaseFirestore.instance.collection('panier').add({
                      'titre': data['titre'],
                      'taille': data['taille'],
                      'prix': data['prix']?.toString(), // Convert to String if necessary
                      'categorie': data['categorie'],
                      'marque': data['marque'],
                      'image': data['image'],
                    }).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vêtement ajouté au panier!')),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PanierPage()),
                      );
                    }).catchError((error) {
                      print('Échec de l\'ajout au panier: $error');
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00afb9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  ),
                  child: const Text('Ajouter au panier', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailText(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 16,
          ),
          children: [
            TextSpan(
              text: value?.toString() ?? 'Non disponible',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
