import 'package:flutter/material.dart';

class PrivacySecurity extends StatefulWidget {
  const PrivacySecurity({super.key});

  @override
  State<PrivacySecurity> createState() => _PrivacySecurityState();
}

class _PrivacySecurityState extends State<PrivacySecurity> {
  bool is2FAEnabled = false;
  bool isProfilePrivate = false;
  bool isLocationSharing = true;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _changePassword() {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showMessage("Please fill all password fields");
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage("Passwords do not match");
    } else {
      _showMessage("Password updated successfully");
      _passwordController.clear();
      _confirmPasswordController.clear();
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy & Security"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 🔐 Password Section
          Text(
            "Change Password",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "New Password",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),

          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),

          ElevatedButton(
            onPressed: _changePassword,
            child: Text("Update Password"),
          ),

          SizedBox(height: 30),

          // 🔒 Security Settings
          Text(
            "Security Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SwitchListTile(
            title: Text("Enable Two-Factor Authentication"),
            value: is2FAEnabled,
            onChanged: (value) {
              setState(() {
                is2FAEnabled = value;
              });
            },
          ),

          SwitchListTile(
            title: Text("Private Profile"),
            value: isProfilePrivate,
            onChanged: (value) {
              setState(() {
                isProfilePrivate = value;
              });
            },
          ),

          SwitchListTile(
            title: Text("Location Sharing"),
            value: isLocationSharing,
            onChanged: (value) {
              setState(() {
                isLocationSharing = value;
              });
            },
          ),

          SizedBox(height: 30),

          // 🛡 Privacy Actions
          Text(
            "Privacy Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text("Delete Account"),
            onTap: () {
              _showMessage("Account deletion feature coming soon");
            },
          ),

          ListTile(
            leading: Icon(Icons.lock, color: Colors.blue),
            title: Text("Manage Permissions"),
            onTap: () {
              _showMessage("Permission settings coming soon");
            },
          ),
        ],
      ),
    );
  }
}