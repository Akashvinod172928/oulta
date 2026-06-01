import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';

import 'package:oulta/features/presentation/social/controller/social_controller.dart';
import 'package:oulta/features/presentation/social/widgets/impact_stand_card.dart';
import 'package:oulta/features/presentation/social/widgets/campaign_card.dart';
import 'package:oulta/features/presentation/social/widgets/victory_card.dart';

import 'package:oulta/features/leaderboard/leaderboard_screen.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final SocialController socialController = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        socialController.fetchMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("o    /${socialController.currentCommunity.value}");
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          kToolbarHeight,
        ), // Standard app bar height
        child: Obx(
          () => CustomAppBar(
            title: 'o/${socialController.currentCommunity.value}',
            trailingIcon: Icons.leaderboard_outlined,
            onTrailingIconPressed: () =>
                Get.to(() => const LeaderboardScreen()),
          ),
        ),
      ),

      body: Column(
        children: [
          // Community Description Header
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    'o/${socialController.currentCommunity.value}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    'Welcome to the ${socialController.currentCommunity.value} community! Discuss, share, and make an impact together.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 8), // Spacing before divider/tabs
              ],
            ),
          ),
          // Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                _buildTab('Impact Stands'),
                _buildTab('Campaigns'),
                _buildTab('Victories'),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (socialController.selectedTab.value == 'Impact Stands') {
                if (socialController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return socialController.impactStands.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'COMING SOON',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The first impact stands are being prepared.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: socialController.impactStands.length,
                        itemBuilder: (context, index) {
                          return ImpactStandCard(
                            impactStand: socialController.impactStands[index],
                          );
                        },
                      );
              } else if (socialController.selectedTab.value == 'Campaigns') {
                if (socialController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return socialController.campaigns.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.campaign_outlined,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Campaigns yet.',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: socialController.campaigns.length,
                        itemBuilder: (context, index) {
                          return CampaignCard(
                            campaign: socialController.campaigns[index],
                          );
                        },
                      );
              } else if (socialController.selectedTab.value == 'Victories') {
                if (socialController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return socialController.victoryStands.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Victories yet.',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: socialController.victoryStands.length,
                        itemBuilder: (context, index) {
                          return VictoryCard(
                            victory: socialController.victoryStands[index],
                          );
                        },
                      );
              }

              // Fallback (Empty or strictly hidden Posts)
              return const SizedBox.shrink();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    return Expanded(
      child: Obx(() {
        final isSelected = socialController.selectedTab.value == title;

        return GestureDetector(
          onTap: () => socialController.selectedTab.value = title,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade300,
                width: 1,
              ),
              // Square corners: No borderRadius
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12, // Reduced font size
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ),
        );
      }),
    );
  }
}
