import 'package:flutter/material.dart';

class ActivityLog extends StatelessWidget {
  ActivityLog({super.key});

  final List<Map<String, String>> activities = [
    {
      "title": "Logged In",
      "time": "2026-04-14 10:30 AM",
      "icon": "login"
    },
    {
      "title": "Updated Profile",
      "time": "2026-04-14 11:00 AM",
      "icon": "edit"
    },
    {
      "title": "Placed Order",
      "time": "2026-04-13 08:45 PM",
      "icon": "shopping"
    },
    {
      "title": "Logged Out",
      "time": "2026-04-13 09:00 PM",
      "icon": "logout"
    },
  ];

  IconData getIcon(String type) {
    switch (type) {
      case "login":
        return Icons.login;
      case "logout":
        return Icons.logout;
      case "edit":
        return Icons.edit;
      case "shopping":
        return Icons.shopping_cart;
      default:
        return Icons.info;
    }
  }

  Color getColor(String type) {
    switch (type) {
      case "login":
        return Colors.green;
      case "logout":
        return Colors.red;
      case "edit":
        return Colors.blue;
      case "shopping":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Log"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getColor(activity["icon"]!),
                child: Icon(
                  getIcon(activity["icon"]!),
                  color: Colors.white,
                ),
              ),
              title: Text(activity["title"]!),
              subtitle: Text(activity["time"]!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}