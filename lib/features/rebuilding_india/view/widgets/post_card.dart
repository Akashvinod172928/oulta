import 'package:flutter/material.dart';

// --- Data Models ---

class Post {
  final User author;
  final String text;
  final DateTime timestamp;
  final int score;
  final NGO? postedByNgo;

  Post({
    required this.author,
    required this.text,
    required this.timestamp,
    this.score = 0,
    this.postedByNgo,
  });
}

class User {
  final String handle; // u/ashak
  final String displayName;
  final int dharmaPoints;
  final String rank; // e.g., "Initiate"
  final String shortBio;

  User({
    required this.handle,
    required this.displayName,
    this.dharmaPoints = 0,
    this.rank = "Initiate",
    this.shortBio = "",
  });
}

class NGO {
  final String handle; // ngo/hopefoundation
  final String name;
  final bool isVerified;

  NGO({
    required this.handle,
    required this.name,
    this.isVerified = false,
  });
}


// --- PostCard Widget ---

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int _score;
  bool _upvoted = false;
  bool _downvoted = false;

  @override
  void initState() {
    super.initState();
    _score = widget.post.score;
  }

  void _handleUpvote() {
    setState(() {
      if (_upvoted) {
        _score--;
        _upvoted = false;
      } else {
        if (_downvoted) {
          _score += 2;
          _downvoted = false;
        } else {
          _score++;
        }
        _upvoted = true;
      }
    });
  }

  void _handleDownvote() {
    setState(() {
      if (_downvoted) {
        _score++;
        _downvoted = false;
      } else {
        if (_upvoted) {
          _score -= 2;
          _upvoted = false;
        } else {
          _score--;
        }
        _downvoted = true;
      }
    });
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xFFDDE1E6);
    const secondaryTextColor = Color(0xFF8A8A8E);
    const accentColor = Color(0xFF00D1FF);
    const cardBackgroundColor = Color(0xFF1A1A1C); // Slightly lighter than canvas

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vote control
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  color: _upvoted ? accentColor : secondaryTextColor,
                ),
                onPressed: _handleUpvote,
                splashRadius: 20,
              ),
              Text(
                _score.toString(),
                style: TextStyle(
                  color: _upvoted ? accentColor : (_downvoted ? Colors.blueAccent : primaryTextColor),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.arrow_downward_rounded,
                  color: _downvoted ? accentColor : secondaryTextColor,
                ),
                onPressed: _handleDownvote,
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Post content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.author.handle,
                      style: const TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(color: secondaryTextColor, fontSize: 14),
                    ),
                    Text(
                      _formatTime(widget.post.timestamp),
                      style: const TextStyle(color: secondaryTextColor, fontSize: 14),
                    ),
                    if (widget.post.postedByNgo != null) ...[
                      const Text(
                        ' • via ',
                        style: TextStyle(color: secondaryTextColor, fontSize: 14),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.post.postedByNgo!.handle,
                            style: const TextStyle(
                              color: accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.post.postedByNgo!.isVerified)
                            const Icon(Icons.verified, color: accentColor, size: 16),
                        ],
                      )
                    ]
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.post.text,
                  style: const TextStyle(
                    color: primaryTextColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // More options
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.more_horiz, color: secondaryTextColor),
            onPressed: () {
              // TODO: Show Report/Save menu
            },
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
