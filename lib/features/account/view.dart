// AccountScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/common/routes/routename.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/smallCardDharma.dart';
import 'controller.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NameController nameController = Get.put(NameController());
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Account',
          onTrailingIconPressed: () => Get.toNamed(RouteName.settings),
        ),
        body: Obx(() {
          if (nameController.isLoading.value &&
              !nameController.isLoggedIn.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!nameController.isLoggedIn.value) {
            return _buildLoginScreen(nameController);
          }

          if (!nameController.isNameSet.value) {
            return _buildNameSetupScreen(nameController);
          }

          return _buildAccountScreen(context, nameController);
        }),
      ),
    );
  }

  // 🔹 Login Screen
  Widget _buildLoginScreen(NameController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 30),
            Text(
              'Welcome to Kakaka',
              style: Get.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sign in to continue and personalize your experience',
              style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // 🔹 Google Sign-In Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.signInWithGoogle(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey[700],
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image.asset(
                    //   'assets/images/google_logo.png',
                    //   height: 20,
                    //   width: 20,
                    // ),
                    const SizedBox(width: 10),
                    const Text('Sign in with Google'),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 20),
            Text(
              'By signing in, you agree to our Terms of Service and Privacy Policy',
              style:
              Get.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Name Setup Screen
  Widget _buildNameSetupScreen(NameController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            controller.userPhotoUrl.value.isNotEmpty
                ? CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(controller.userPhotoUrl.value),
            )
                : Icon(Icons.person, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 20),
            Text(
              'Welcome!',
              style: Get.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (controller.userEmail.value.isNotEmpty)
              Text(
                controller.userEmail.value,
                style: Get.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 5),
            Text(
              'Let\'s complete your profile',
              style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.showNameDialog(),
              icon: controller.isLoading.value
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.person_add),
              label: Text(controller.isLoading.value
                  ? 'Saving...'
                  : 'Complete Profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15),
              ),
            )),
          ],
        ),
      ),
    );
  }

  // 🔹 Account Screen
  Widget _buildAccountScreen(BuildContext context, NameController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: ListView(
        children: [
          const SizedBox(height: 20),
          Column(
            children: [
              controller.userPhotoUrl.value.isNotEmpty
                  ? CircleAvatar(
                radius: 50,
                backgroundImage:
                NetworkImage(controller.userPhotoUrl.value),
              )
                  : CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Obx(() => Text(
                controller.userName.value,
                style: Theme.of(context).textTheme.headlineSmall,
              )),
              Obx(() => Text(
                controller.userEmail.value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              )),
              Chip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    SizedBox(width: 5),
                    Text('Google Account'),
                  ],
                ),
                backgroundColor: Colors.green[50],
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(),

          // 🔹 Dharma Points Card
          // 🔹 Dharma Points Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() =>  SmallCardDharma(
                // accentIcon: Icons.change_circle,
                title: controller.dharma.value.toString(),
                actionText: 'Dharma',
                iconBackgroundColor: Colors.indigo,
              ),
              ),
              SmallCardDharmaDummy()
            ],
          ),
          const SizedBox(height: 10),

          // // 🔹 Button to update Dharma
          // Obx(() => ElevatedButton(
          //   onPressed: () {
          //     // Example: increment Dharma by 10
          //     controller.updateDharma(controller.dharma.value + 10);
          //   },
          //   child: Text("Add +10 Dharma (Now: ${controller.dharma.value})"),
          // )),
          //
          // const SizedBox(height: 20),
          //
          // // 🔹 Debug Container showing Firestore Data
          // Obx(() => Card(
          //   elevation: 2,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Padding(
          //     padding: const EdgeInsets.all(16),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text("Firestore Data",
          //             style: Theme.of(context)
          //                 .textTheme
          //                 .titleMedium
          //                 ?.copyWith(fontWeight: FontWeight.bold)),
          //         const SizedBox(height: 10),
          //         Text("UID: ${controller.userId}"),
          //         Text("Name: ${controller.userName.value}"),
          //         Text("Email: ${controller.userEmail.value}"),
          //         Text("Photo: ${controller.userPhotoUrl.value}"),
          //         Text("Dharma: ${controller.dharma.value}"),
          //       ],
          //     ),
          //   ),
          // )),

          // const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.logout, color: Colors.red),
          //   title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          //   onTap: () {
          //     Get.defaultDialog(
          //       title: "Sign Out",
          //       middleText: "Are you sure you want to sign out?",
          //       textConfirm: "Sign Out",
          //       textCancel: "Cancel",
          //       confirmTextColor: Colors.white,
          //       onConfirm: () {
          //         Get.back();
          //         controller.signOut();
          //       },
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}