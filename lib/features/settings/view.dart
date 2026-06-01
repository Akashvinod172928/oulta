import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/dharma/what_is_dharma_screen.dart';
import 'package:oulta/features/settings/about_oulta_page.dart';
import 'package:oulta/features/settings/change_account_screen.dart';
import 'package:oulta/features/settings/create_impact_stand_screen.dart';
import 'package:oulta/features/settings/create_campaign_screen.dart';
import 'package:oulta/features/settings/contact_us_screen.dart';
import 'package:oulta/features/support/support_screen.dart';
import 'package:oulta/features/settings/subscription_screen.dart';
import 'package:oulta/features/settings/impact_grants_screen.dart';
import '../../common/widgets/custom_app_bar.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';
import 'package:oulta/common/routes/routename.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NameController nameController = Get.put(NameController());
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const CustomAppBar(title: 'Settings', hasActionButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('GENERAL INFORMATION'),
            _buildSettingsGroup([
              _buildSettingsItem(
                context,
                Icons.info,
                'About Oulta',
                () {
                  Get.to(() => const AboutOultaPage());
                },
              ),
              Obx(() => nameController.profileType.value == 'ngo'
                  ? _buildSettingsItem(
                      context,
                      Icons.campaign,
                      'Create a Campaign',
                      () {
                        Get.to(() => const CreateCampaignScreen());
                      },
                    )
                  : _buildSettingsItem(
                      context,
                      Icons.campaign,
                      'Create an Impact Stand',
                      () {
                        Get.to(() => const CreateImpactStandScreen());
                      },
                    )),
            ]),
            const SizedBox(height: 32),
            Obx(() {
              if (nameController.profileType.value == 'admin') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('ADMIN TOOLS'),
                    _buildSettingsGroup([
                      _buildSettingsItem(
                        context,
                        Icons.emoji_events,
                        'Create Victory Stand (Campaign)',
                        () {
                          Get.toNamed(RouteName.createVictory);
                        },
                      ),
                      _buildSettingsItem(
                        context,
                        Icons.emoji_events_outlined,
                        'Create Victory Stand (Impact)',
                        () {
                          Get.toNamed(RouteName.createImpactVictory);
                        },
                      ),
                    ]),
                    const SizedBox(height: 32),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            _buildSectionHeader('HELP & SUPPORT'),
            _buildSettingsGroup([
              _buildSettingsItem(
                context,
                Icons.help,
                'Support',
                () {
                  Get.to(() => const SupportScreen());
                },
              ),
              _buildSettingsItem(
                context,
                Icons.headphones_outlined,
                'Contact Us',
                () {
                  Get.to(() => const ContactUsScreen());
                },
              ),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader('ACCOUNT & REWARDS'),
            _buildSettingsGroup([
              _buildSettingsItem(
                context,
                Icons.sync,
                'Dharma Points',
                () {
                  Get.to(() => const WhatIsDharmaScreen());
                },
              ),
              _buildSettingsItem(
                context,
                Icons.emoji_events_outlined,
                'Impact Grants',
                () {
                  Get.to(() => const ImpactGrantsScreen());
                },
              ),
              _buildSettingsItem(
                context,
                Icons.star,
                'Subscription',
                () {
                  Get.to(() => const SubscriptionScreen());
                },
              ),
              _buildSettingsItem(
                context,
                Icons.badge,
                'Change Account Type',
                () {
                  Get.to(() => const ChangeAccountScreen());
                },
              ),
            ]),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showLogoutBottomSheet(context, nameController);
                },
                icon: const Icon(Icons.logout, color: Colors.black),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Oulta v2.9.102 — Made for Change',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7), // Light grey, like in the design
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final int index = entry.key;
          final Widget child = entry.value;
          if (index != children.length - 1) {
            return Column(
              children: [
                child,
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[300], // Subdued divider
                ),
              ],
            );
          }
          return child;
        }).toList(),
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context, NameController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to sign out?',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0), // Square
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0), // Square
                      ),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        icon,
        color: color ?? Colors.black87,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.black87,
      ),
      onTap: onTap,
    );
  }
}
