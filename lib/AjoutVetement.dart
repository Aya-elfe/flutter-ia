import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/services.dart';

class AddVetementPage extends StatefulWidget {
  const AddVetementPage({Key? key}) : super(key: key);

  @override
  _AddVetementPageState createState() => _AddVetementPageState();
}

class _AddVetementPageState extends State<AddVetementPage> {
  final _formKey = GlobalKey<FormState>();
  String? _titre; // Nouveau champ pour le titre
  int? _size;
  String? _brand;
  double? _price;
  XFile? _image;
  bool _isLoading = false;

  final Color mainColor = const Color.fromARGB(255, 0, 175, 185);

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<void> _saveVetement() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        List<int> imageBytes = await _image!.readAsBytes();
        String base64Image = base64Encode(imageBytes);

        // Enregistrer les détails du vêtement avec le champ titre
        await FirebaseFirestore.instance.collection('vetements').add({
          'titre': _titre, // Ajouter le titre
          'taille': _size,
          'marque': _brand,
          'prix': _price,
          'image': base64Image,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Vêtement ajouté avec succès!'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur lors de l\'ajout du vêtement: $e'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Uint8List> _getImageBytes() async {
    return await _image!.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter Vêtement'),
        backgroundColor: mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCustomTextField(
                labelText: 'Titre',
                onChanged: (value) => _titre = value,
                validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer le titre' : null,
              ),
              const SizedBox(height: 15),
              _buildCustomTextField(
                labelText: 'Taille',
                onChanged: (value) {
                  _size = int.tryParse(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la taille';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer une taille valide';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              _buildCustomTextField(
                labelText: 'Marque',
                onChanged: (value) => _brand = value,
                validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer la marque' : null,
              ),
              const SizedBox(height: 15),
              _buildCustomTextField(
                labelText: 'Prix',
                onChanged: (value) => _price = double.tryParse(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un prix valide';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Restrict to digits only
              ),
              const SizedBox(height: 20),
              _image == null
                  ? const Text('Aucune image sélectionnée.')
                  : FutureBuilder<Uint8List>(
                      future: _getImageBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Erreur lors du chargement de l\'image');
                        } else if (snapshot.hasData) {
                          return kIsWeb
                              ? Image.memory(snapshot.data!)
                              : Image.file(File(_image!.path));
                        } else {
                          return const Text('Erreur inconnue');
                        }
                      },
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                ),
                child: const Text('Choisir une image'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveVetement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text('Valider', style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required String labelText,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters, // Added inputFormatters parameter
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: mainColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: mainColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: mainColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: mainColor, width: 2),
        ),
      ),
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters, // Set inputFormatters here
    );
  }
}
