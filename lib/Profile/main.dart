import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'activityLog.dart';
import 'editDetails.dart';
import 'privacy_security.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InvoSmart Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "Admin User";
  String _email = "admin@invosmart.com";
  String _phone = "0123456789";
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _openEditDetails() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditDetails(
          name: _name,
          email: _email,
          phone: _phone,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _name = result['name'] ?? _name;
        _email = result['email'] ?? _email;
        _phone = result['phone'] ?? _phone;
      });
    }
  }

  Future<void> _pickProfilePhoto(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null) return;

      setState(() {
        _profileImageFile = File(image.path);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not pick image")),
      );
    }
  }

  Future<void> _showImageSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfilePhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfilePhoto(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImageFile != null
                        ? FileImage(_profileImageFile!)
                        : const NetworkImage('https://via.placeholder.com/150')
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: _showImageSourcePicker,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // User Info
            Text(
              _name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _email,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            // Action List
            ProfileMenuItem(
              icon: Icons.edit,
              title: "Edit Details",
              onTap: _openEditDetails,
            ),
            ProfileMenuItem(
              icon: Icons.history,
              title: "Activity Log",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivityLog()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.security,
              title: "Privacy & Security",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacySecurity()),
                );
              },
            ),
            const Divider(),
            ProfileMenuItem(
              icon: Icons.logout,
              title: "Logout",
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logout tapped")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for profile rows
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.textColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.blueGrey),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.black87, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}