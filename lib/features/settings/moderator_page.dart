import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/moderator/user_control_page.dart'; // Import the new page

class ModeratorPage extends StatelessWidget {
  const ModeratorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderator Tools'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Content Moderation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildToolCard(
            context,
            title: 'Review Reported Content',
            subtitle: 'View and take action on reported posts and comments.',
            icon: Icons.report,
            onTap: () {
              // TODO: Implement navigation to content review page
              Get.snackbar('In Development', 'This feature is not yet available.');
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'User Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildToolCard(
            context,
            title: 'User Control', // New button
            subtitle: 'Manage user roles and status.',
            icon: Icons.people,
            onTap: () => Get.to(() => const UserControlPage()), // Route to the new page
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
