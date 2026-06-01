import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';
import 'package:oulta/features/presentation/account/widgets/account_shimmer.dart';
import 'package:oulta/features/presentation/profile/controller/profile_controller.dart';
import 'package:oulta/features/presentation/profile/widgets/profile_body.dart';

class UserProfilePage extends StatelessWidget {
  final String username;
  final String? userId; // Optional: pass Firestore doc ID to skip name-based lookup

  const UserProfilePage({Key? key, required this.username, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(
      ProfileController(userHandle: username, userId: userId),
      tag: username,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: username),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AccountShimmer();
        }

        if (!controller.userFound.value ||
            controller.viewedUser.value == null) {
          return const Center(
            child: Text(
              'User not found.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ProfileBody(
          user: controller.viewedUser.value!,
          showFollowButton: !controller.isOwnProfile,
          controller: controller,
        );
      }),
    );
  }
}
