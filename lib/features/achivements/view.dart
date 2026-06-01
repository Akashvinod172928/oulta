import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';
import 'package:oulta/features/achivements/badge_model.dart';
import '../../common/widgets/custom_app_bar.dart';
import 'badge_details_page.dart';

class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final NameController nameController = Get.find<NameController>();
    final String lockedBadgeAsset = 'assets/badges/default_badge.png';

    return Scaffold(
      appBar: const CustomAppBar(title: 'Achievements'),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Limited',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Exclusive, short-run badges',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              final earnedIds = nameController.earnedBadgeIds;

              // Create a fresh list of badges and update their unlocked status
              final List<BadgeItem> displayBadges = allBadges.map((badge) {
                final bool isUnlocked = earnedIds.contains(badge.id);
                return BadgeItem(
                  id: badge.id,
                  title: badge.title,
                  subtitle: badge.subtitle,
                  description: badge.description,
                  imageAsset: badge.imageAsset,
                  numberAwarded: badge.numberAwarded,
                  totalAvailable: badge.totalAvailable,
                  progress: isUnlocked ? 1 : 0,
                  goal: 1,
                  unlockedDate: isUnlocked ? 'Today' : null,
                );
              }).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: displayBadges.length,
                itemBuilder: (context, index) {
                  final badge = displayBadges[index];
                  final imageToShow = badge.unlocked
                      ? badge.imageAsset
                      : lockedBadgeAsset;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: badge.unlocked
                            ? Colors.grey[200]!
                            : Colors.grey[100]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            badge.unlocked ? 0.04 : 0.02,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => Get.to(() => BadgeDetailsPage(badge: badge)),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: badge.unlocked ? 1.0 : 0.3,
                                  child: Image.asset(
                                    imageToShow,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.error_outline_rounded,
                                              size: 60,
                                            ),
                                  ),
                                ),
                                if (!badge.unlocked)
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.grey[400],
                                    size: 24,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              badge.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: badge.unlocked
                                    ? Colors.black
                                    : Colors.grey[400],
                              ),
                            ),
                            if (badge.unlocked) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'UNLOCKED',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
