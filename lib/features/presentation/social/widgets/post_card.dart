import 'package:flutter/material.dart';
import 'package:oulta/common/widgets/universal_image.dart';

enum VoteState { none, up, down }

// Updated Post model with all required fields
class Post {
  final String id;
  final String authorHandle;
  final String authorPhotoUrl;
  final String title;
  final String? description;
  final DateTime timestamp;
  final int score;
  final int commentCount;
  final String? ngoHandle;
  final String? companyHandle;
  final bool isVerified;
  final VoteState myVote;
  final String communityHandle;
  final String? locationState;
  final String? locationDistrict;

  bool get isNgo => ngoHandle != null && ngoHandle!.isNotEmpty;
  bool get isCompany => companyHandle != null && companyHandle!.isNotEmpty;

  Post({
    required this.id,
    required this.authorHandle,
    required this.authorPhotoUrl,
    required this.title,
    this.description,
    required this.timestamp,
    this.score = 0,
    this.commentCount = 0,
    this.ngoHandle,
    this.companyHandle,
    this.isVerified = false,
    this.myVote = VoteState.none,
    required this.communityHandle,
    this.locationState,
    this.locationDistrict,
  });
}

class PostCard extends StatelessWidget {
  final Post post;
  final Function(VoteState currentVote, bool isUpvoteButton) onVote;
  final VoidCallback? onComment;
  final VoidCallback? onUsernameTap;
  final bool showCommunityIcon;

  const PostCard({
    Key? key,
    required this.post,
    required this.onVote,
    this.onComment,
    this.onUsernameTap,
    this.showCommunityIcon = false,
  }) : super(key: key);

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    const Color actionIconColor = Color(0xFFABB1B7);
    const Color upvoteColor = Color(0xFFFF4500);
    const Color downvoteColor = Color(0xFF7193FF);

    return GestureDetector(
      onTap: onComment,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPostHeader(context),
                  const SizedBox(height: 12),
                  _buildPostContent(context),
                  const SizedBox(height: 16),
                  _buildPostActions(
                    actionIconColor,
                    upvoteColor,
                    downvoteColor,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    final isNgo = post.isNgo;
    final isCompany = post.isCompany;
    final handle = isNgo
        ? post.ngoHandle!
        : (isCompany ? post.companyHandle! : post.authorHandle); // NGO, Company or User name
    final prefix = isNgo ? 'ngo/' : (isCompany ? 'c/' : (post.isVerified ? '' : 'u/'));

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[100],
            backgroundImage: post.authorPhotoUrl.isNotEmpty
                ? getUniversalImageProvider(post.authorPhotoUrl)
                : null,
            child: post.authorPhotoUrl.isEmpty
                ? Icon(Icons.person_rounded, size: 20, color: Colors.grey[400])
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onUsernameTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Community Icon (Only if enabled)
                    if (!isNgo && showCommunityIcon) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage(
                            post.communityHandle == 'kerala'
                                ? 'assets/social_icons/kerala_icon.png'
                                : 'assets/social_icons/indian_logo.png',
                          ),
                        ),
                      ),
                    ],
                    if (post.isVerified && !isNgo)
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          Icons.verified,
                          size: 14,
                          color: Colors.blue,
                        ),
                      ),
                    Text(
                      '$prefix$handle',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatTime(post.timestamp),
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_horiz_rounded, color: Colors.grey[400]),
          onPressed: () {
            /* TODO: options */
          },
          tooltip: 'More',
        ),
      ],
    );
  }

  Widget _buildPostContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
            height: 1.3,
            letterSpacing: -0.3,
          ),
        ),
        if (post.description != null && post.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              post.description!,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (post.locationState != null && post.locationDistrict != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.locationDistrict}, ${post.locationState}',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPostActions(
    Color actionIconColor,
    Color upvoteColor,
    Color downvoteColor,
  ) {
    final isUpvoted = post.myVote == VoteState.up;
    final isDownvoted = post.myVote == VoteState.down;
    final scoreColor = isUpvoted
        ? upvoteColor
        : (isDownvoted ? downvoteColor : Colors.black87);

    return Row(
      children: [
        // Vote Pill
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  isUpvoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                  color: isUpvoted ? upvoteColor : Colors.grey[600],
                  size: 18,
                ),
                onPressed: () => onVote(post.myVote, true),
                splashRadius: 20,
              ),
              Text(
                '${post.score}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  isDownvoted
                      ? Icons.thumb_down_rounded
                      : Icons.thumb_down_outlined,
                  color: isDownvoted ? downvoteColor : Colors.grey[600],
                  size: 18,
                ),
                onPressed: () => onVote(post.myVote, false),
                splashRadius: 20,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Comment Pill
        if (onComment != null)
          GestureDetector(
            onTap: onComment,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    post.commentCount.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),

        const Spacer(),

        // Share Button
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              color: Colors.white,
            ),
            child: Icon(
              Icons.share_outlined,
              color: Colors.grey[600],
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
