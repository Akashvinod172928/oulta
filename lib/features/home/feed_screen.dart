import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/home/community_controller.dart';
import 'package:oulta/features/presentation/social/controller/social_controller.dart';
import 'package:oulta/features/impact_news/view/impact_news_feed_section.dart';
import '../../common/routes/routename.dart';
import '../../common/widgets/custom_app_bar.dart';

class FeedScreen extends StatelessWidget {
  FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CommunityController>()) {
      Get.put(CommunityController());
    }
    final communityController = Get.find<CommunityController>();
    final socialController = Get.find<SocialController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'EXPLORE',
        hasActionButton: false,
        hasLeadingButton: false,
      ),
      body: Obx(() {
        final joinedIds = communityController.joinedIds;
        // India is always the first one
        final indiaData = kAllCommunities.firstWhere((c) => c.id == 'india');
        final showSections = joinedIds.contains('__none__');
        
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            const _SearchCard(),
            const SizedBox(height: 10),
            const ImpactNewsFeedSection(),
            if (showSections) ...[
              // ── Your Communities (Joined) ──────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Your Communities',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111111),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              
              // India Card
              _CommunityCard(
                community: indiaData,
                memberCount: 2400, // Static for now
                onTap: () {
                  socialController.switchCommunity('india');
                  Get.toNamed(RouteName.social);
                },
              ),

              // Other Joined Communities
              ...joinedIds.map((id) {
                final data = kAllCommunities.firstWhere((c) => c.id == id);
                return _CommunityCard(
                  community: data,
                  memberCount: 850, // Static for now
                  onTap: () {
                    socialController.switchCommunity(id);
                    Get.toNamed(RouteName.social);
                  },
                  onLeave: () => communityController.toggleCommunity(id),
                );
              }),
            ],

            const SizedBox(height: 20),

            if (showSections) ...[
              // ── Explore More (Other Communities) ────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Explore Communities',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111111),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              
              // The "As Earlier" Explore Card
              _ExploreCommunityCard(
                onTap: () {
                  // In the previous version this opened a modal, 
                  // but since we want the list here, we could either 
                  // scroll to it or just show the tiles below.
                },
              ),

              const SizedBox(height: 10),
              
              // The list of non-joined communities (as requested: "inside the container at bottom as earlier")
              _CommunityExploreList(
                excludeIds: ['india', ...joinedIds],
              ),
            ],

            const SizedBox(height: 120),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Community Card (The big one from earlier home screen)
// ─────────────────────────────────────────────────────────────

class _CommunityCard extends StatelessWidget {
  final CommunityData community;
  final int memberCount;
  final VoidCallback onTap;
  final VoidCallback? onLeave;

  const _CommunityCard({
    required this.community,
    required this.memberCount,
    required this.onTap,
    this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  community.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${community.id == 'india' ? 'National' : 'State'} Community',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8A8A92),
                      ),
                    ),
                  ],
                ),
              ),
              if (onLeave != null)
                IconButton(
                  onPressed: onLeave,
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFF8A8A92), size: 20),
                )
              else
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF8A8A92), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Explore Community Card (The horizontal emoji row)
// ─────────────────────────────────────────────────────────────

class _ExploreCommunityCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ExploreCommunityCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explore More',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover other states and interest groups',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: kAllCommunities
                      .where((c) => c.id != 'india')
                      .take(5)
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _EmojiChip(emoji: c.emoji),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const Icon(Icons.add_circle_outline_rounded, size: 32, color: Colors.black),
        ],
      ),
    );
  }
}

class _EmojiChip extends StatelessWidget {
  final String emoji;
  const _EmojiChip({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 16)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Search card
// ─────────────────────────────────────────────────────────────

class _SearchCard extends StatelessWidget {
  const _SearchCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(RouteName.search),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.04), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE4E4E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded, color: Colors.black),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF171717),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Find causes, NGOs and campaigns that match your values.',
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: Color(0xFF6B6B6F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withOpacity(0.18),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Community tile list (For non-joined)
// ─────────────────────────────────────────────────────────────

class _CommunityExploreList extends StatelessWidget {
  final List<String> excludeIds;
  const _CommunityExploreList({required this.excludeIds});

  @override
  Widget build(BuildContext context) {
    final CommunityController controller = Get.find<CommunityController>();
    final SocialController socialController = Get.find<SocialController>();

    final remainingCommunities = kAllCommunities
        .where((c) => !excludeIds.contains(c.id))
        .toList();

    if (remainingCommunities.isEmpty) return const SizedBox.shrink();

    final specialCommunities = remainingCommunities
        .where((c) => c.category == 'special')
        .toList();
    final stateCommunities =
        remainingCommunities.where((c) => c.category == 'state').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (specialCommunities.isNotEmpty) ...[
          const _SectionLabel(label: '✨  Featured'),
          ...specialCommunities.map((c) => _CommunityTile(
              community: c, controller: controller, socialController: socialController)),
        ],
        if (stateCommunities.isNotEmpty) ...[
          const SizedBox(height: 12),
          const _SectionLabel(label: '🗺️  State Communities'),
          ...stateCommunities.map((c) => _CommunityTile(
              community: c, controller: controller, socialController: socialController)),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8A8A92),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CommunityTile extends StatelessWidget {
  final CommunityData community;
  final CommunityController controller;
  final SocialController socialController;

  const _CommunityTile({
    required this.community,
    required this.controller,
    required this.socialController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final joined = controller.isJoined(community.id);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            socialController.switchCommunity(community.id);
            Get.toNamed(RouteName.social);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // Emoji avatar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: joined
                        ? Colors.black
                        : const Color(0xFFF2F2F4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    community.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),

                const SizedBox(width: 13),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'o/${community.id}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        community.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        community.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8A92),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Join / Joined button
                GestureDetector(
                  onTap: () => controller.toggleCommunity(community.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: joined ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: joined
                            ? Colors.black.withOpacity(0.25)
                            : Colors.black,
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      joined ? 'Joined' : 'Join',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: joined
                            ? const Color(0xFF333333)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
