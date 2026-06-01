import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/home/community_controller.dart';
import 'package:oulta/features/presentation/social/controller/social_controller.dart';
import 'package:oulta/features/presentation/social/widgets/impact_stand_card.dart';
import 'package:oulta/features/presentation/social/widgets/campaign_card.dart';
import 'package:oulta/features/presentation/social/widgets/victory_card.dart';
import '../../common/widgets/custom_app_bar.dart';

class OultaScreen extends StatelessWidget {
  const OultaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CommunityController>()) {
      Get.put(CommunityController());
    }
    final socialController = Get.find<SocialController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'OULTA',
        hasLeadingButton: false,
        hasActionButton: false,
      ),
      body: Column(
        children: [
          // ── Tab bar ─────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                _HomeTab(title: 'Impact Stands', controller: socialController),
                const SizedBox(width: 8),
                _HomeTab(title: 'Campaigns', controller: socialController),
                const SizedBox(width: 8),
                _HomeTab(title: 'Victories', controller: socialController),
              ],
            ),
          ),

          // ── Filter Row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Currently selected filter indication
                Obx(() {
                  final filter = socialController.homeCommunityFilter.value;
                  final filterName = filter == 'all'
                      ? 'All Communities'
                      : kAllCommunities.firstWhere((c) => c.id == filter).name;
                  final filterEmoji = filter == 'all'
                      ? '🌍'
                      : kAllCommunities.firstWhere((c) => c.id == filter).emoji;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(filterEmoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          filterName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Filter Button
                GestureDetector(
                  onTap: () => _showFilterBottomSheet(context, socialController),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.tune_rounded, size: 16, color: Colors.black),
                        SizedBox(width: 6),
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Feed ─────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final tab = socialController.homeSelectedTab.value;
              final filter = socialController.homeCommunityFilter.value;

              if (socialController.homeIsLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (tab == 'Impact Stands') {
                final stands = socialController.homeImpactStands
                    .where((s) =>
                        s.status != 'victory' &&
                        (filter == 'all' || s.community == filter))
                    .toList();
                if (stands.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.auto_awesome_outlined,
                    message: 'No Impact Stands yet.',
                    sub: 'Join more communities to see stands from across India.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: stands.length,
                  itemBuilder: (context, index) => ImpactStandCard(
                    impactStand: stands[index],
                    showCommunityTag: true,
                  ),
                );
              }

              if (tab == 'Campaigns') {
                final allHomeCampaigns = socialController.homeCampaigns;
                print("DEBUG UI: Total home campaigns: ${allHomeCampaigns.length}");
                for (var c in allHomeCampaigns) {
                  print("DEBUG UI: Campaign: ${c.name}, Status: ${c.status}");
                }

                final campaigns = allHomeCampaigns
                    .where((c) =>
                        c.status != 'victory' &&
                        (filter == 'all' || c.community == filter))
                    .toList();
                if (campaigns.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.campaign_outlined,
                    message: 'No Campaigns yet.',
                    sub: 'Join more communities to see campaigns from across India.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) => CampaignCard(
                    campaign: campaigns[index],
                    showCommunityTag: true,
                  ),
                );
              }

              // Victories tab - Use the actual victory stands from victory_stands collection
              final victories = socialController.homeVictoryStands
                  .where((v) =>
                      filter == 'all' ||
                      v.campaignCommunity.trim().toLowerCase() == filter.trim().toLowerCase())
                  .toList();

              if (victories.isEmpty) {
                return const _EmptyState(
                  icon: Icons.emoji_events_outlined,
                  message: 'No Victories yet.',
                  sub: 'Victories are celebrated here once a campaign succeeds.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: victories.length,
                itemBuilder: (context, index) {
                  return VictoryCard(
                    victory: victories[index],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Helper to show a beautiful bottom sheet filter interface
  void _showFilterBottomSheet(BuildContext context, SocialController socialController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempSelected = socialController.homeCommunityFilter.value;
        bool isExpanded = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E4E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111111),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Accordion filter options
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.people_outline_rounded, color: Colors.black87),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Community Filter',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF111111),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          tempSelected == 'all'
                                              ? 'All Communities'
                                              : kAllCommunities.firstWhere((c) => c.id == tempSelected).name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black.withOpacity(0.5),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (isExpanded) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Divider(height: 1, thickness: 1),
                          ),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              children: [
                                _buildCommunityOption(
                                  context,
                                  id: 'all',
                                  name: 'All Communities',
                                  emoji: '🌍',
                                  isSelected: tempSelected == 'all',
                                  onSelect: () => setState(() => tempSelected = 'all'),
                                ),
                                ...kAllCommunities
                                    .where((c) => c.id == 'india' || c.id == 'kerala')
                                    .map((c) {
                                  return _buildCommunityOption(
                                    context,
                                    id: c.id,
                                    name: c.name,
                                    emoji: c.emoji,
                                    isSelected: tempSelected == c.id,
                                    onSelect: () => setState(() => tempSelected = c.id),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions row (Cancel & OK)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(color: Colors.black.withOpacity(0.15)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            socialController.homeCommunityFilter.value = tempSelected;
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Builds a community option inside the filter bottom sheet list
  Widget _buildCommunityOption(
    BuildContext context, {
    required String id,
    required String name,
    required String emoji,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black.withOpacity(0.04) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.black : const Color(0xFF333333),
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.black,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }}

// ─────────────────────────────────────────────────────────────
// Tab pill widget
// ─────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final String title;
  final SocialController controller;

  const _HomeTab({required this.title, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.homeSelectedTab.value == title;
        return GestureDetector(
          onTap: () => controller.homeSelectedTab.value = title,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : const Color(0xFFF2F2F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF6B6B70),
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Empty-state widget
// ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Kept for any external references (post_card, etc.)
// ─────────────────────────────────────────────────────────────

class CampaignGroupCard extends StatelessWidget {
  final String coverImageAsset;
  final String centerImageAsset;
  final String title;
  final String oultaSocial;
  final String visibilityText;
  final String membersText;
  final VoidCallback onTap;

  const CampaignGroupCard({
    super.key,
    required this.coverImageAsset,
    required this.centerImageAsset,
    required this.title,
    required this.oultaSocial,
    required this.visibilityText,
    required this.membersText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border:
                Border.all(color: Colors.black.withOpacity(0.04), width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22)),
                  child: Image.asset(
                    coverImageAsset,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  child: Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        oultaSocial,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B6B70),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.public_rounded,
                              size: 18, color: Color(0xFF6B6B70)),
                          const SizedBox(width: 6),
                          Text(visibilityText,
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF6B6B70))),
                          const SizedBox(width: 16),
                          const Icon(Icons.people_alt_rounded,
                              size: 18, color: Color(0xFF6B6B70)),
                          const SizedBox(width: 6),
                          Text(membersText,
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF6B6B70))),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 110,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 34,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: AssetImage(centerImageAsset),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
