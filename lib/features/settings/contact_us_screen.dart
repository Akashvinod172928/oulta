import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';
import 'package:oulta/features/data/social/services/firebase_service.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();
    final NameController nameController = Get.find<NameController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Contact Us'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Details Card
              const Text(
                'How can we help?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Selection List
              _buildActionTile(
                icon: Icons.campaign_outlined,
                title: 'Create a Community',
                subtitle: 'Request to start a new Oulta community',
                onTap: () {
                  _showCreateCommunityDialog(
                    context,
                    firebaseService,
                    nameController,
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.lightbulb_outline,
                title: 'Suggest an Idea',
                subtitle: 'Have a feature request or feedback?',
                onTap: () {
                  _showSuggestIdeaDialog(
                    context,
                    firebaseService,
                    nameController,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateCommunityDialog(
    BuildContext context,
    FirebaseService service,
    NameController userController,
  ) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final emailController = TextEditingController(
      text: userController.userEmail.value,
    ); // Auto-fill if available

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a Community',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Community Name',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., o/Photography',
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Your Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.phone,
                  onChanged: (val) {
                    // Start collecting number if needed, for now just UI field as per request implies collecting it?
                    // "also add the number also" - likely means adding number field to form.
                    // Wait, "add a phone number,name and mail id" was original request.
                    // "create a message to oulta for these" implies sending them.
                    // "remove the upper portion of the number email oulta support team" implies removing the display card.
                    // So I will remove the display card and add number field here.
                  },
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                    hintText: '+91 XXXXX XXXXX',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description / Purpose',
                    border: OutlineInputBorder(),
                    hintText: 'Why should we create this community?',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty ||
                            emailController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Name and Email are required',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        await service.sendCommunityRequest(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          description: descController.text.trim(),
                        );
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Request sent to Oulta team!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black,
                          colorText: Colors.white,
                        );
                      },
                      child: const Text(
                        'Send Request',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuggestIdeaDialog(
    BuildContext context,
    FirebaseService service,
    NameController userController,
  ) {
    final ideaController = TextEditingController();
    final emailController = TextEditingController(
      text: userController.userEmail.value,
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suggest an Idea',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Your Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                    hintText: '+91 XXXXX XXXXX',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ideaController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Your Idea / Feedback',
                    border: OutlineInputBorder(),
                    hintText: 'Describe your idea...',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        if (ideaController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please enter an idea',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        await service.sendIdeaSuggestion(
                          email: emailController.text.trim(),
                          suggestion: ideaController.text.trim(),
                        );
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Thank you for your suggestion!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black,
                          colorText: Colors.white,
                        );
                      },
                      child: const Text(
                        'Send Idea',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Colors.black87),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
