import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text("Settings Screen"),

          Column(
            children: [
              clickableCard("User Interface", Icons.settings, () {}),
              clickableCard(
                "Notification Settings",
                Icons.notifications,
                () {},
              ),
              clickableCard("Help", Icons.help, () {}),
              clickableCard("About", Icons.info, () {}),
            ],
          ),

          Spacer(),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget clickableCard(String text, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: () {
          // Handle card tap
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.settings, size: 24, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
