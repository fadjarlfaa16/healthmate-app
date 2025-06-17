import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _nameController = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;
  String? _initialImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['profile']?['fullname'] ?? '';
        _initialImageUrl = data['profile']?['imagePath'];
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera && !kIsWeb) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
        return;
      }
    }

    final XFile? picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 30,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
      });
    }
  }

  Future<String?> _uploadToSupabase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final bytes = _imageBytes;
    final name = _imageName;
    if (uid == null || bytes == null || name == null) return null;

    final ext = name.split('.').last;
    final fileName = 'users/${uid}_${const Uuid().v4()}.$ext';
    final storage = Supabase.instance.client.storage.from('img-profile');
    try {
      // uploadBinary throws on error
      await storage.uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
      return storage.getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Upload exception: $e');
      return null;
    }
  }

  Future<void> _updateProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);
    String? imageUrl;
    if (_imageBytes != null) {
      imageUrl = await _uploadToSupabase();
    }
    final updateData = {'profile.fullname': _nameController.text.trim()};
    if (imageUrl != null) updateData['profile.imagePath'] = imageUrl;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(updateData);
    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? avatar;
    if (_imageBytes != null) {
      avatar = MemoryImage(_imageBytes!);
    } else if (_initialImageUrl != null) {
      avatar = NetworkImage(_initialImageUrl!);
    } else {
      avatar = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Uploading...', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                )
                : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap:
                            () => showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder:
                                  (_) => SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            Icons.photo_library,
                                          ),
                                          title: const Text(
                                            'Choose from Gallery',
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage(ImageSource.gallery);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt),
                                          title: const Text('Take a Photo'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage(ImageSource.camera);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: avatar,
                          child:
                              avatar == null
                                  ? const Icon(
                                    Icons.camera_alt,
                                    size: 32,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _updateProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
