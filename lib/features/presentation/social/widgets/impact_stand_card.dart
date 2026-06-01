import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:oulta/common/widgets/universal_image.dart';
import 'package:oulta/features/home/community_controller.dart';
import 'package:oulta/common/routes/routename.dart';

class ImpactStand {
  final String id;
  final String standId; // Added Stand ID
  final String name; // Used as heading
  final String subHeading;
  final String description;
  final String type; // The type of impact stand
  final List<dynamic> whoShouldAct;
  final String community;
  final List<String> photoUrls;
  int standCount;
  int commentCount;
  bool hasTakenStand;
  final String creatorId; // Added for edit permissions
  final String creatorEmail; // Save email for tracking
  final String creatorName; // Added for display
  final DateTime? timestamp;
  final String status; // 'active' or 'victory'
  final bool isPetition; // Added for stand type

  ImpactStand({
    required this.id,
    this.standId = '',
    required this.name,
    this.subHeading = '',
    this.description = '',
    required this.type,
    this.whoShouldAct = const [],
    required this.community,
    this.photoUrls = const [],
    this.standCount = 0,
    this.commentCount = 0,
    this.hasTakenStand = false,
    required this.creatorId,
    this.creatorEmail = '',
    this.creatorName = 'Anonymous',
    this.timestamp,
    this.status = 'active',
    this.isPetition = false,
  });
}

class ImpactStandCard extends StatelessWidget {
  final ImpactStand impactStand;
  /// When true, shows a prominent community pill (emoji + name) above the title.
  final bool showCommunityTag;

  const ImpactStandCard({
    Key? key,
    required this.impactStand,
    this.showCommunityTag = false,
  }) : super(key: key);

  /// Look up the emoji for a community id from kAllCommunities.
  String _communityEmoji(String id) {
    try {
      return kAllCommunities.firstWhere((c) => c.id == id).emoji;
    } catch (_) {
      return '🌐';
    }
  }

  String _communityName(String id) {
    try {
      return kAllCommunities.firstWhere((c) => c.id == id).name;
    } catch (_) {
      return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('${RouteName.impactStandDetail}?id=${impactStand.id}', arguments: impactStand);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo with Overlay
            Stack(
              children: [
                // Image section — NO Hero here to rule out Hero conflicts
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: impactStand.photoUrls.isNotEmpty
                      ? UniversalImage(
                          imageUrl: impactStand.photoUrls.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        )
                      : SvgPicture.asset(
                          'assets/social_icons/Black and Purple Gradient Coming Soon A4 Landscape.svg',
                          fit: BoxFit.cover,
                          placeholderBuilder: (context) => Container(
                            color: Colors.black87,
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.white54,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                ),
                // Stand Count Badge
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.flag_rounded,
                          color: Colors.black,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          impactStand.isPetition
                              ? '${impactStand.standCount} Signed'
                              : '${impactStand.standCount} Taken',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (impactStand.status == 'victory')
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.black,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'VICTORY',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Community pill — shown prominently when showCommunityTag is true
                  if (showCommunityTag) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _communityEmoji(impactStand.community),
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _communityName(impactStand.community),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'o/${impactStand.community}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (impactStand.timestamp != null)
                        Text(
                          '•  ${DateFormat('MMM d').format(impactStand.timestamp!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${impactStand.commentCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Hero(
                    tag: 'stand_title_${impactStand.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        impactStand.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(
                          '${RouteName.impactStandDetail}?id=${impactStand.id}',
                          arguments: impactStand,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              impactStand.hasTakenStand
                                  ? 'View Stand'
                                  : 'Take Stand',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
