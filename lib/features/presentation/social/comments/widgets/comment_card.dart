import 'package:flutter/material.dart';
import 'package:oulta/features/presentation/social/widgets/post_card.dart'; // For VoteState

class Comment {
  final String id;
  final String? parentId;
  final String authorHandle;
  final String authorPhotoUrl;
  final String text;
  final DateTime timestamp;
  final int score;
  final int replyCount;
  final VoteState myVote;
  Comment({
    required this.id,
    this.parentId,
    required this.authorHandle,
    required this.authorPhotoUrl,
    required this.text,
    required this.timestamp,
    this.score = 0,
    this.replyCount = 0,
    this.myVote = VoteState.none,
  });
}

class CommentCard extends StatelessWidget {
  final Comment comment;
  final Function(VoteState currentVote, bool isUpvoteButton) onVote;
  final VoidCallback onUsernameTap;
  final VoidCallback? onReport;

  const CommentCard({
    Key? key,
    required this.comment,
    required this.onVote,
    required this.onUsernameTap,
    this.onReport,
  }) : super(key: key);

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF1A1A1B);
    const Color secondaryTextColor = Color(0xFF787C7E);
    const Color actionIconColor = Color(0xFF878A8C);
    const Color upvoteColor = Color(0xFFFF4500);
    const Color downvoteColor = Color(0xFF7193FF);

    final isUpvoted = comment.myVote == VoteState.up;
    final isDownvoted = comment.myVote == VoteState.down;
    final scoreColor = isUpvoted
        ? upvoteColor
        : (isDownvoted ? downvoteColor : primaryTextColor);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onUsernameTap,
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              radius: 18,
              backgroundImage: comment.authorPhotoUrl.isNotEmpty
                  ? NetworkImage(comment.authorPhotoUrl)
                  : null,
              child: comment.authorPhotoUrl.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.black26,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: onUsernameTap,
                              child: Text(
                                'u/${comment.authorHandle}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: primaryTextColor,
                                  fontSize: 14,
                                  letterSpacing: -0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Text(
                            ' • ${_formatTime(comment.timestamp)}',
                            style: const TextStyle(
                              color: secondaryTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Use a proper menu for options
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_horiz,
                        color: actionIconColor,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      // Reduced hit area for better alignment
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'report' && onReport != null) {
                          onReport!();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.flag_outlined,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Report',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(
                    color: primaryTextColor,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionRow(
                  actionIconColor,
                  upvoteColor,
                  downvoteColor,
                  scoreColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    Color actionIconColor,
    Color upvoteColor,
    Color downvoteColor,
    Color scoreColor,
  ) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            comment.myVote == VoteState.up
                ? Icons.thumb_up
                : Icons.thumb_up_alt_outlined,
            color: comment.myVote == VoteState.up
                ? upvoteColor
                : actionIconColor,
            size: 18,
          ),
          onPressed: () => onVote(comment.myVote, true),
          splashRadius: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            comment.score.toString(),
            key: ValueKey<int>(comment.score),
            style: TextStyle(
              color: scoreColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            comment.myVote == VoteState.down
                ? Icons.thumb_down
                : Icons.thumb_down_alt_outlined,
            color: comment.myVote == VoteState.down
                ? downvoteColor
                : actionIconColor,
            size: 18,
          ),
          onPressed: () => onVote(comment.myVote, false),
          splashRadius: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const Spacer(),
      ],
    );
  }
}
