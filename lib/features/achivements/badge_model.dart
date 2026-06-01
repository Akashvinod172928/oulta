class BadgeItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageAsset;
  final int numberAwarded;
  final int totalAvailable;

  // Added missing fields to support details page
  int progress;
  int goal;
  String? unlockedDate;

  BadgeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageAsset,
    required this.numberAwarded,
    required this.totalAvailable,
    this.progress = 0,
    this.goal = 1,
    this.unlockedDate,
  });

  // Added missing getters
  bool get unlocked => progress >= goal;
  double get progressFraction => goal == 0 ? 1.0 : (progress / goal).clamp(0.0, 1.0);
}

// Central source of truth for all badges in the app
final List<BadgeItem> allBadges = [
  BadgeItem(
    id: 'first_light',
    title: 'First Light',
    subtitle: 'Founding IMPACTISM,\n Your light changed everything',
    description: 'You are the spark that started it all.\nAs an Oulta Firstlight Founder, you didn’t just join—you became the heartbeat of a new era.\nYour courage and vision lit the path for real impact, inspiring a movement that will shape the future.',
    numberAwarded: 10,
    totalAvailable: 5040,
    imageAsset: 'assets/badges/firstlight.png',
  ),

  BadgeItem(
    id: 'goat',
    title: 'Goat',
    subtitle: 'Greatest of All Time',
    description: 'Awarded for exceptional long-term contribution.',
    imageAsset: 'assets/badges/goat_badge.png',
    numberAwarded: 1234,
    totalAvailable: 5000,
  ),
  BadgeItem(
    id: 'impact_duo',
    title: 'Impact Duo',
    subtitle: 'Teamwork Makes It Happen',
    description: 'Awarded for collaborative posts that created big impact.',
    imageAsset: 'assets/badges/impact_duo.png',
    numberAwarded: 876,
    totalAvailable: 10000,
  ),
  BadgeItem(
    id: 'wonder_woman',
    title: 'Wonder Woman',
    subtitle: 'Celebrating Women Who Lead',
    description: 'Awarded for impactful contributions to women-led causes.',
    imageAsset: 'assets/badges/wond_women.png',
    numberAwarded: 500,
    totalAvailable: 1000,
  ),
];
