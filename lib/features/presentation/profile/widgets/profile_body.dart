import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/profile/controller/profile_controller.dart';
import 'package:oulta/features/presentation/social/widgets/impact_stand_card.dart';
import 'package:oulta/features/presentation/social/widgets/campaign_card.dart';
import 'package:oulta/features/presentation/social/widgets/post_card.dart';
import 'package:oulta/features/presentation/social/comments/widgets/comment_card.dart';
import 'package:oulta/features/presentation/social/comments/view/comment_screen.dart';
import 'package:oulta/common/widgets/smallCardDharma.dart';
import 'package:oulta/features/achivements/view.dart';
import 'package:oulta/features/domain/account/entities/account_user.dart';
import 'package:oulta/features/presentation/account/view/edit_profile_screen.dart';
import 'package:oulta/features/presentation/account/view/edit_ngo_profile_screen.dart';
import 'package:oulta/features/dharma/dharma_detail_screen.dart';

class ProfileBody extends StatelessWidget {
  final AccountUser user;
  final bool showFollowButton;
  final bool isOwnProfile;
  final ProfileController? controller;

  const ProfileBody({
    Key? key,
    required this.user,
    this.showFollowButton = false,
    this.isOwnProfile = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(this);
  }
}

class _ProfileSection extends StatelessWidget {
  final ProfileBody data;
  const _ProfileSection(this.data);

  @override
  Widget build(BuildContext context) {
    final user = data.user;
    final controller = data.controller;

    if (controller == null)
      return const Center(child: CircularProgressIndicator());
      
    final bool isNgo = user.profileType == 'ngo';
    final bool isCompany = user.profileType == 'company';
    final int tabLength = isCompany ? 2 : 3;

    return RefreshIndicator(
      onRefresh: () => controller.refreshPage(),
      color: Colors.black,
      child: DefaultTabController(
        length: tabLength,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  children: [
                    _ProfileHeader(
                      isNgo: isNgo,
                      isCompany: isCompany,
                      user: user,
                      isOwnProfile: data.isOwnProfile,
                    ),
                    if (data.showFollowButton) ...[
                      const SizedBox(height: 20),
                      _FollowButton(controller),
                    ],
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  indicatorWeight: 3,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  tabs: [
                    if (!isNgo && !isCompany) const Tab(text: "Impact Stands"),
                    if (isNgo) const Tab(text: "Campaigns"),
                    const Tab(text: "Victories"),
                    const Tab(text: "Comments"),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              if (!isNgo && !isCompany) _CreatedStandsList(controller: controller),
              if (isNgo) _UserCampaignsList(controller: controller),

              // Victories (Posts) Tab
              _UserPostsList(controller: controller),

              // Comments Tab
              _UserCommentsList(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _UserCampaignsList extends StatelessWidget {
  final ProfileController controller;
  const _UserCampaignsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCampaigns.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          ),
        );
      }

      if (controller.userCampaigns.isEmpty) {
        return const _EmptyState(
          icon: Icons.campaign_outlined,
          message: "No campaigns created yet",
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: controller.userCampaigns.length,
        itemBuilder: (context, index) {
          final campaign = controller.userCampaigns[index];
          return CampaignCard(campaign: campaign);
        },
      );
    });
  }
}

class _CreatedStandsList extends StatelessWidget {
  final ProfileController controller;
  const _CreatedStandsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingImpactStands.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          ),
        );
      }

      final stands = controller.userImpactStands;

      if (stands.isEmpty) {
        return _EmptyState(
          icon: Icons.volunteer_activism_outlined,
          message: "No Impact Stands created yet",
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: stands.length,
        itemBuilder: (context, index) {
          final stand = stands[index];
          return ImpactStandCard(impactStand: stand);
        },
      );
    });
  }
}

class _UserPostsList extends StatelessWidget {
  final ProfileController controller;
  const _UserPostsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPosts.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
        );
      }

      final posts = controller.userPosts;
      if (posts.isEmpty) {
        return _EmptyState(
          icon: Icons.article_outlined,
          message: "No victories posted yet",
        );
      }

      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            post: post,
            onVote: (vote, isUp) => controller.votePost(post.id, vote, isUp),
            onComment: () {
              Get.to(() => CommentScreen(post: post));
            },
          );
        },
      );
    });
  }
}

class _UserCommentsList extends StatelessWidget {
  final ProfileController controller;
  const _UserCommentsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingComments.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
        );
      }

      final comments = controller.userComments;
      if (comments.isEmpty) {
        return _EmptyState(
          icon: Icons.chat_bubble_outline_rounded,
          message: "No comments yet",
        );
      }

      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: comments.length,
        itemBuilder: (context, index) {
          final comment = comments[index];
          return CommentCard(
            comment: comment,
            onVote: (vote, isUp) =>
                {}, // Voting on profile results is tricky, skipping for now
            onUsernameTap: () {}, // Already on the profile
          );
        },
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final bool isNgo;
  final bool isCompany;
  final AccountUser user;
  final bool isOwnProfile;

  const _ProfileHeader({
    required this.isNgo,
    required this.isCompany,
    required this.user,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = isNgo
        ? (user.ngoName.isNotEmpty ? user.ngoName : user.name)
        : (isCompany
              ? (user.companyName.isNotEmpty ? user.companyName : user.name)
              : user.name);
    final displayLogo = isNgo && user.ngoLogo.isNotEmpty
        ? user.ngoLogo
        : (isCompany && user.companyLogo.isNotEmpty
              ? user.companyLogo
              : user.photoUrl);
    final displayTagline = isNgo
        ? (user.ngoMission.isNotEmpty
              ? user.ngoMission
              : 'An NGO making a difference')
        : (isCompany
              ? (user.csrDetails.isNotEmpty
                    ? user.csrDetails
                    : (user.companyIndustry.isNotEmpty
                          ? user.companyIndustry
                          : 'A purpose-driven company'))
              : (user.tagline.isNotEmpty ? user.tagline : 'No tagline yet'));
    final displayHandle = isNgo 
        ? 'ngo/$displayName' 
        : (isCompany ? 'c/$displayName' : 'u/$displayName');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: ClipOval(
                child: displayLogo.isNotEmpty
                    ? Image.network(
                        displayLogo,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(isNgo, isCompany),
                      )
                    : _buildPlaceholder(isNgo, isCompany),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            letterSpacing: -0.5,
                            color: Colors.black,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayHandle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  if (displayTagline.isNotEmpty)
                    Text(
                      displayTagline,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
            _buildStatPill('${user.followerCount}', 'Followers'),
            if (user.location.isNotEmpty)
              _buildIconPill(Icons.location_on, user.location.toString()),
            if (isOwnProfile)
              GestureDetector(
                onTap: () {
                  if (isNgo) {
                    Get.to(() => const EditNgoProfileScreen());
                  } else {
                    Get.to(() => const EditProfileScreen());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.edit, color: Colors.black87, size: 14),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Get.to(() => DharmaDetailScreen(dharmaPoints: user.dharma)),
                child: SmallCardDharma(
                  title: 'Dharma',
                  actionText: '${user.dharma}',
                  iconBackgroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => Get.to(() => const AchievementsView()),
                child: SmallCardAchievements(
                  title: 'Badges',
                  actionText: '${user.earnedBadgeIds.length} Badges',
                  iconBackgroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlaceholder(bool isNgo, bool isCompany) {
    return Center(
      child: Icon(
        isNgo 
            ? Icons.business 
            : (isCompany ? Icons.domain_rounded : Icons.person),
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildStatPill(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 13,
              ),
            ),
            TextSpan(
              text: ' $label',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final ProfileController controller;
  const _FollowButton(this.controller);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.toggleFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isFollowing.value
                ? Colors.white
                : Colors.black,
            foregroundColor: controller.isFollowing.value
                ? Colors.black
                : Colors.white,
            side: controller.isFollowing.value
                ? const BorderSide(color: Colors.black)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(controller.isFollowing.value ? 'Following' : 'Follow'),
        ),
      ),
    );
  }
}
