import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:oulta/common/widgets/universal_image.dart';
import 'package:oulta/features/home/community_controller.dart';
import 'package:oulta/features/presentation/social/widgets/campaign_card.dart';
import 'package:oulta/features/presentation/social/widgets/impact_stand_card.dart';
import 'package:oulta/features/presentation/social/view/campaign_detail_page.dart';
import 'package:oulta/common/routes/routename.dart';

class VictoryStand {
  final String id;
  final String campaignStandId;
  final String campaignId;
  final String companyId;
  final String companyName;
  final String victoryTitle;
  final String victoryDescription;
  final List<String> beforeImages;
  final List<String> afterImages;
  final DateTime createdAt;
  final String victoryNote;
  final List<dynamic> victoryWhoActed;

  // Transferred Campaign/ImpactStand Snapshot properties
  final String campaignName;
  final String campaignSubHeading;
  final String campaignDescription;
  final String campaignType;
  final List<dynamic> campaignWhoShouldAct;
  final String campaignCommunity;
  final List<String> campaignPhotoUrls;
  final int campaignStandCount;
  final String campaignCreatorId;
  final String campaignCreatorName;
  final String campaignCreatorEmail;
  final bool isImpactStand;

  VictoryStand({
    required this.id,
    required this.campaignStandId,
    required this.campaignId,
    required this.companyId,
    required this.companyName,
    required this.victoryTitle,
    required this.victoryDescription,
    required this.beforeImages,
    required this.afterImages,
    required this.createdAt,
    this.victoryNote = '',
    this.victoryWhoActed = const [],
    required this.campaignName,
    required this.campaignSubHeading,
    required this.campaignDescription,
    required this.campaignType,
    required this.campaignWhoShouldAct,
    required this.campaignCommunity,
    required this.campaignPhotoUrls,
    required this.campaignStandCount,
    required this.campaignCreatorId,
    required this.campaignCreatorName,
    required this.campaignCreatorEmail,
    this.isImpactStand = false,
  });
}

class VictoryCard extends StatelessWidget {
  final VictoryStand victory;
  /// When true, shows a prominent community pill (emoji + name) above the title.
  final bool showCommunityTag;

  const VictoryCard({
    super.key,
    required this.victory,
    this.showCommunityTag = false,
  });

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

  void _navigateToDetail() {
    final hasCampaign = victory.campaignName.isNotEmpty;
    if (!hasCampaign) {
      Get.snackbar(
        "Info",
        victory.isImpactStand
            ? "Impact Stand details are not available for this victory stand."
            : "Campaign details are not available for this victory stand.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (victory.isImpactStand) {
      final List<Map<String, String>> mappedWho = [];
      for (final item in victory.campaignWhoShouldAct) {
        if (item is Map) {
          mappedWho.add(Map<String, String>.from(
            item.map((key, value) => MapEntry(key.toString(), value.toString())),
          ));
        }
      }

      final impactStand = ImpactStand(
        id: victory.campaignId,
        standId: victory.campaignStandId,
        name: victory.campaignName,
        subHeading: victory.campaignSubHeading,
        description: victory.campaignDescription,
        type: victory.campaignType,
        whoShouldAct: mappedWho,
        community: victory.campaignCommunity,
        photoUrls: victory.campaignPhotoUrls,
        standCount: victory.campaignStandCount,
        commentCount: 0,
        hasTakenStand: false,
        creatorId: victory.campaignCreatorId,
        creatorEmail: victory.campaignCreatorEmail,
        creatorName: victory.campaignCreatorName,
        timestamp: null,
        status: 'victory',
        isPetition: false,
      );

      Get.toNamed(
        '${RouteName.impactStandDetail}?id=${impactStand.id}',
        arguments: impactStand,
      );
    } else {
      final campaign = Campaign(
        id: victory.campaignId,
        standId: victory.campaignStandId,
        name: victory.campaignName,
        subHeading: victory.campaignSubHeading,
        description: victory.campaignDescription,
        type: victory.campaignType,
        whoShouldAct: victory.campaignWhoShouldAct,
        community: victory.campaignCommunity,
        photoUrls: victory.campaignPhotoUrls,
        standCount: victory.campaignStandCount,
        commentCount: 0,
        hasTakenStand: false,
        creatorId: victory.campaignCreatorId,
        creatorEmail: victory.campaignCreatorEmail,
        creatorName: victory.campaignCreatorName,
        timestamp: null,
        status: 'victory',
        companyName: victory.companyName,
        victoryTitle: victory.victoryTitle,
        victoryDescription: victory.victoryDescription,
      );
      Get.to(
        () => CampaignDetailPage(campaign: campaign),
        transition: Transition.rightToLeft,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCampaign = victory.campaignName.isNotEmpty;

    return GestureDetector(
      onTap: _navigateToDetail,
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
            // Photo with Overlaid Badges
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: victory.campaignPhotoUrls.isNotEmpty
                      ? UniversalImage(
                          imageUrl: victory.campaignPhotoUrls.first,
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
                // Supporters / Taken Count Badge (Bottom Right overlay)
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
                          Icons.people_outline,
                          color: Colors.black,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${victory.campaignStandCount} Supporters',
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
                // VICTORY Trophy Badge (Top Left overlay)
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
            // Content Padding
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
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _communityEmoji(victory.campaignCommunity),
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _communityName(victory.campaignCommunity),
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
                  // Victory Tag & Creation Date Metadata Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'VICTORY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  ${DateFormat('MMM d').format(victory.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Victory Title
                  Hero(
                    tag: 'victory_title_${victory.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        victory.victoryTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Victory Description
                  Text(
                    victory.victoryDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Corporate Sponsor / Acting Authority Banner (Uniform height, single-line)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: victory.isImpactStand
                          ? Colors.indigo.shade50.withOpacity(0.4)
                          : Colors.teal.shade50.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: victory.isImpactStand
                            ? Colors.indigo.shade100.withOpacity(0.5)
                            : Colors.teal.shade100.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          victory.isImpactStand
                              ? Icons.account_balance
                              : Icons.domain,
                          size: 16,
                          color: victory.isImpactStand
                              ? Colors.indigo.shade700
                              : Colors.teal.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            victory.isImpactStand
                                ? "Resolved by: ${victory.companyName.isNotEmpty ? victory.companyName : 'Government/Authority'}"
                                : "Corporate Sponsor: ${victory.companyName}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: victory.isImpactStand
                                  ? Colors.indigo.shade900
                                  : Colors.teal.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Original Campaign Metadata Row & Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasCampaign)
                        Expanded(
                          child: Text(
                            victory.isImpactStand
                                ? "Impact Stand: ${victory.campaignName}"
                                : "Campaign: ${victory.campaignName}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _navigateToDetail,
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
                            children: const [
                              Text(
                                'View Victory',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
