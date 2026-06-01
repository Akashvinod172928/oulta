import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/home/community_controller.dart';
import 'package:oulta/features/presentation/social/controller/social_controller.dart';
import '../../common/routes/routename.dart';

class CommunitiesPage extends StatelessWidget {
  const CommunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CommunityController>()) {
      Get.put(CommunityController());
    }

    final stateCommunities =
        kAllCommunities.where((c) => c.category == 'state').toList();
    final specialCommunities = kAllCommunities
        .where((c) => c.category == 'special' && c.id != 'india')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
        ),
        title: const Text(
          'Communities',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111111),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.black.withOpacity(0.06),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 120),
        children: [
          // ── Featured / Special ────────────────────────────
          _SectionHeader(title: '✨  Featured'),
          ...specialCommunities.map(
              (c) => _CommunityTile(community: c)),

          const SizedBox(height: 8),

          // ── State Communities ─────────────────────────────
          _SectionHeader(title: '🗺️  State Communities'),
          ...stateCommunities.map(
              (c) => _CommunityTile(community: c)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
      child: Text(
        title,
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

// ─────────────────────────────────────────────────────────────
// Community List Tile
// ─────────────────────────────────────────────────────────────

class _CommunityTile extends StatelessWidget {
  final CommunityData community;
  const _CommunityTile({required this.community});

  @override
  Widget build(BuildContext context) {
    final CommunityController controller = Get.find<CommunityController>();
    final SocialController socialController = Get.find<SocialController>();

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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // ── Emoji avatar ──────────────────────────
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

                // ── Text ─────────────────────────────────
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

                // ── Join / Joined button ──────────────────
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
