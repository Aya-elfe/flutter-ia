import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loginPage.dart';
import 'AjoutVetement.dart'; // Import the form page here
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _login;
  String? _anniversaire;
  String? _adresse;
  String? _ville;
  int? _codePostal;
  String? _newPassword; // Updated for new password input
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _login = user.email;
            _anniversaire = userDoc['anniversaire'] ?? '';
            _adresse = userDoc['adresse'] ?? '';
            _ville = userDoc['ville'] ?? '';
            _codePostal = userDoc['codePostal']?.toInt();
            _isLoading = false;
          });
        } else {
          _showSnackBar('Utilisateur non trouvé dans Firestore');
          setState(() => _isLoading = false);
        }
      } else {
        _showSnackBar('Utilisateur non authentifié');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la récupération du profil: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _updateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Map<String, dynamic> updateData = {
            'anniversaire': _anniversaire,
            'adresse': _adresse,
            'ville': _ville,
            'codePostal': _codePostal,
          };

          // Hash the new password if it’s not empty, then update Firestore
          if (_newPassword != null && _newPassword!.isNotEmpty) {
            updateData['hashedPassword'] = base64.encode(utf8.encode(_newPassword!));
            await user.updatePassword(_newPassword!); // Update the password in Firebase Auth
          }

          await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updateData);
          _showSnackBar('Profil mis à jour avec succès');
        } else {
          _showSnackBar('Utilisateur non authentifié');
        }
      } catch (e) {
        _showSnackBar('Erreur lors de la mise à jour du profil: $e');
      }
    } else {
      _showSnackBar('Veuillez corriger les erreurs avant de valider.');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: _login,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Login',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _anniversaire ?? '',
                          decoration: InputDecoration(
                            labelText: 'Anniversaire (JJ/MM/AAAA)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _anniversaire = value,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _adresse ?? '',
                          decoration: InputDecoration(
                            labelText: 'Adresse',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _adresse = value,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _ville ?? '',
                          decoration: InputDecoration(
                            labelText: 'Ville',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _ville = value,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _codePostal?.toString() ?? '',
                          decoration: InputDecoration(
                            labelText: 'Code Postal',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _codePostal = int.tryParse(value);
                            } else {
                              _codePostal = null;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un code postal.';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Veuillez entrer un code postal valide.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nouveau mot de passe',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          onChanged: (value) => _newPassword = value,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updateUserProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Valider',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const AddVetementPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AFB9),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Ajouter vêtement',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Se déconnecter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}