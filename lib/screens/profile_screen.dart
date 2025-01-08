import 'package:e_travel/core/config/theme/colors.dart';
import 'package:e_travel/features/reviews/repositories/review_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ReviewRepository _reviewRepository = ReviewRepository();
  late User? _user;
  String? _name;
  String? _email;
  String? _profileImageUrl;
  File? _imageFile;
  bool _isUploading = false;

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
        _profileImageUrl = userDoc['profileImage'] ?? '';
        _nameController.text = _name!;
      });
    }
  }

  Future<void> _updateName() async {
    try {
      final userData = {
        'name': _nameController.text,
        'profileImage': _profileImageUrl,
      };

      // Update user's name in users collection
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update({'name': _nameController.text});

      // Update all reviews by this user
      await _reviewRepository.updateUserReviews(_user!.uid, userData);

      setState(() {
        _name = _nameController.text;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _changeProfileImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isUploading = true;
      });

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${_user!.uid}.jpg');

        final uploadTask = storageRef.putFile(_imageFile!);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
        });

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        final userData = {
          'name': _name,
          'profileImage': downloadUrl,
        };

        // Update Firestore user profile and all reviews
        await Future.wait([
          _firestore
              .collection('users')
              .doc(_user!.uid)
              .update({'profileImage': downloadUrl}),
          _user!.updatePhotoURL(downloadUrl),
          _reviewRepository.updateUserReviews(_user!.uid, userData),
        ]);

        setState(() {
          _profileImageUrl = downloadUrl;
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully')),
          );
        }
      } catch (e) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile image: $e')),
          );
        }
      }
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
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _isUploading ? null : _changeProfileImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : _profileImageUrl != null &&
                                      _profileImageUrl!.isNotEmpty
                                  ? NetworkImage(_profileImageUrl!)
                                      as ImageProvider
                                  : const NetworkImage(''),
                        ),
                      ),
                      if (_isUploading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          ),
                        ),
                    ],
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
