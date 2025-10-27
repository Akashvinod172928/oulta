import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../account/controller.dart'; // Assuming this path is correct

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  final NameController nameController = Get.put(NameController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Settings',
          hasActionButton: false,
          // If your CustomAppBar doesn't automatically add a back button,
          // you might need to add one:
          // leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Get.back()),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: <Widget>[

                  _buildSettingsItem(context, Icons.help_outline, 'Support', () {
                    // TODO: Implement navigation/action
                  }),
                  _buildSettingsItem(context, Icons.change_circle, ' Dharma Points', () {
                    // TODO: Implement navigation/action
                  }),

                  _buildSettingsItem(context, Icons.privacy_tip_outlined, 'Privacy', () {
                    // TODO: Implement navigation/action
                  }),
                  _buildSettingsItem(context, Icons.description_outlined, 'Resources & Legal', () {
                    // TODO: Implement navigation/action
                  }),
                  _buildSettingsItem(context, Icons.login_outlined, 'Sign Out',color: Colors.red, () {
                    Get.defaultDialog(
                      title: "Sign Out",
                      middleText: "Are you sure you want to sign out?",
                      textConfirm: "Sign Out",
                      textCancel: "Cancel",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.back();
                        nameController.signOut();
                      },
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  // If you have a specific logo for the app, you can place it here
                  // Example: Icon(Icons.shield_moon_outlined, size: 30, color: Colors.grey[700]),
                  // SizedBox(height: 8),
                  Text(
                    'Version 2.9.102',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, VoidCallback onTap,{Color? color}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color:color ?? Colors.grey[400]),
      onTap: onTap,
    );
  }
}
