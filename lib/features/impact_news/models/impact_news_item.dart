class ImpactNewsItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final String timeAgo;
  final List<String> bulletPoints;
  final int likes;
  final int comments;

  ImpactNewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.timeAgo,
    required this.bulletPoints,
    this.likes = 0,
    this.comments = 0,
  });
}
