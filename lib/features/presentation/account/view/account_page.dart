import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/profile/controller/profile_controller.dart';
import 'package:oulta/features/presentation/profile/widgets/profile_body.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';
import '../controller/account_controller.dart';
import '../widgets/account_shimmer.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NameController nameController = Get.find<NameController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Account',
        hasLeadingButton: false,
        trailingIcon: Icons.settings,
        onTrailingIconPressed: () => Get.toNamed('/settings'),
      ),
      body: Obx(() {
        final state = nameController.screenState.value;
        if (state == ScreenState.loading) {
          return const AccountShimmer();
        }
        if (state == ScreenState.loggedOut) {
          return _buildLoginScreen(nameController);
        }
        // if (state == ScreenState.needsProfileSetup) {2\
        //   return _buildNameSetupScreen(nameController);
        // }
        if (state == ScreenState.loggedIn) {
          return Obx(() {
            final user = nameController.currentUserRx.value;
            if (user == null) return const AccountShimmer();

            final String currentUserHandle = user.name;
            final ProfileController profileController = Get.put(
              ProfileController(userHandle: currentUserHandle),
              tag: currentUserHandle,
            );

            return Obx(() {
              if (profileController.isLoading.value) {
                return const AccountShimmer();
              }
              return ProfileBody(
                user: user,
                showFollowButton: false,
                isOwnProfile: true,
                controller: profileController,
              );
            });
          });
        }
        return const AccountShimmer();
      }),
    );
  }

  Widget _buildLoginScreen(NameController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.white,
          height: constraints.maxHeight,
          child: Column(
            children: [
              // 1. Top Section - Flexible Orb Area
              Expanded(
                flex: 4, // Gives more weight to the top visual
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ambient glow
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blue.withOpacity(0.08),
                            Colors.transparent,
                          ],
                          radius: 0.7,
                        ),
                      ),
                    ),
                    // The "Orb"
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.black, Color(0xFF2C2C2C)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 126,
                          height: 126,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1A1A1A), Colors.black],
                              stops: [0.1, 0.9],
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Image.asset(
                                'assets/app_icon/app_icon_white.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Bottom Section - Fixed Content Area
              Expanded(
                flex: 4, // Less weight than top, holds the interaction elements
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Oulta Access",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Connect your identity to start making\nan impact in the real world.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 25),

                      //   const Spacer(), // Pushes button to bottom
                      // Google Button
                      Obx(
                        () => SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.signInWithGoogle(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          'assets/google.png',
                                          height: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Footer
                      Text(
                        "Terms & Privacy Policy",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Reduced Clearance to fix overflow
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNameSetupScreen(NameController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Please set up your name'),
          ElevatedButton(
            onPressed: () => controller.showNameDialog(),
            child: const Text('Set Name'),
          ),
        ],
      ),
    );
  }
}
