import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _uploadData() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl;

      if (kIsWeb) {
        // Upload image to Firebase Storage for web
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('candidates/${_imageFile!.name}');
        await storageRef.putData(await _imageFile!.readAsBytes());
        imageUrl = await storageRef.getDownloadURL();
      } else {
        // Upload image to Firebase Storage for mobile
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('candidates/${_imageFile!.name}');
        await storageRef.putFile(File(_imageFile!.path));
        imageUrl = await storageRef.getDownloadURL();
      }

      // Check if the user is authenticated
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-authenticated',
          message: 'The user is not authenticated',
        );
      }

      // Get the current year
      String currentYear = DateTime.now().year.toString();

      // Save candidate data to the current year's election document
      await FirebaseFirestore.instance
          .collection('elections')
          .doc('election$currentYear')
          .collection('category')
          .doc(_categoryController.text.toLowerCase().trim())
          .collection('candidates')
          .add({
        'name': _nameController.text.trim(),
        'imageUrl': imageUrl,
        'category': _categoryController.text.trim(),
      });

      setState(() {
        _isLoading = false;
        _nameController.clear();
        _categoryController.clear();
        _imageFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload successful'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 5,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Candidate Name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 5,
                child: TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    hintText: 'Category',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _imageFile == null
                  ? Text('No image selected.')
                  : kIsWeb
                      ? Image.network(_imageFile!.path)
                      : Image.file(File(_imageFile!.path)),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadData,
                      child: Text('Submit'),
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Delete Candidates"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
