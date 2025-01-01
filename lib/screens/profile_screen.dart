import 'package:e_travel/utils/colors.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? _user;
  String? _name;
  String? _email;
  String? _profileImageUrl;
  File? _imageFile; // To hold the selected image

  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();
      setState(() {
        _name = userDoc['name'];
        _email = userDoc['email'];
        _profileImageUrl =
            userDoc['profileImage'] ?? ''; // Or set to a default image
        _nameController.text = _name!;
      });
    }
  }

  Future<void> _updateName() async {
    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .update({'name': _nameController.text});
    setState(() {
      _name = _nameController.text; // Update state to reflect changes
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated successfully')));
  }

  Future<void> _changeProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      print('Picked image file path: ${pickedFile.path}');

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${_user!.uid}.jpg');

        // Start the upload
        final uploadTask = storageRef.putFile(_imageFile!);
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          // See progress if needed
          print(
              'Upload progress: ${snapshot.bytesTransferred} / ${snapshot.totalBytes}');
        });

        final snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          // Image uploaded successfully
          final downloadUrl = await snapshot.ref.getDownloadURL();
          print('Uploaded image URL: $downloadUrl');

          await _firestore
              .collection('users')
              .doc(_user!.uid)
              .update({'profileImage': downloadUrl});

          setState(() {
            _profileImageUrl = downloadUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully')),
          );
        } else {
          print('Upload task failed with state: ${snapshot.state}');
        }
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    } else {
      print('No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: AppColors.secondaryColor,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _changeProfileImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : _profileImageUrl != null &&
                                  _profileImageUrl!.isNotEmpty
                              ? NetworkImage(_profileImageUrl!)
                              : const NetworkImage(
                                  'https://img.freepik.com/free-photo/young-male-posing-isolated-against-blank-studio-wall_273609-12356.jpg'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _name ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _email ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Edit Name',
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.blueAccent, width: 2.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save),
                        color: Colors.blueAccent,
                        onPressed: _updateName,
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
