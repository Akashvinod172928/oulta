import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:oulta/common/widgets/universal_image.dart';
import 'package:oulta/features/home/community_controller.dart';
import 'package:oulta/features/presentation/social/view/campaign_detail_page.dart';

class Campaign {
  final String id;
  final String standId; // Added Stand ID
  final String name; 
  final String subHeading;
  final String description;
  final String type; 
  final List<dynamic> whoShouldAct;
  final String community;
  final List<String> photoUrls;
  int standCount;
  int commentCount;
  bool hasTakenStand;
  final String creatorId; 
  final String creatorEmail; 
  final String creatorName; 
  final DateTime? timestamp;
  final String status; 
  
  // Optional Victory Details
  final String companyName;
  final String victoryTitle;
  final String victoryDescription;

  Campaign({
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
    this.companyName = '',
    this.victoryTitle = '',
    this.victoryDescription = '',
  });
}

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  /// When true, shows a prominent community pill (emoji + name) above the title.
  final bool showCommunityTag;

  const CampaignCard({
    Key? key,
    required this.campaign,
    this.showCommunityTag = false,
  }) : super(key: key);

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
        Get.to(() => CampaignDetailPage(campaign: campaign));
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
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: campaign.photoUrls.isNotEmpty
                      ? UniversalImage(
                          imageUrl: campaign.photoUrls.first,
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
                          '${campaign.standCount} Taken',
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
                if (campaign.status == 'victory')
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
                            'SUCCESS',
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
                                _communityEmoji(campaign.community),
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _communityName(campaign.community),
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
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          campaign.type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (campaign.timestamp != null)
                        Text(
                          '•  ${DateFormat('MMM d').format(campaign.timestamp!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Hero(
                    tag: 'campaign_title_${campaign.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        campaign.name,
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
                  Text(
                    campaign.subHeading,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Get.to(() => CampaignDetailPage(campaign: campaign));
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
                              campaign.hasTakenStand ? 'View Stand' : 'Take Stand',
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
