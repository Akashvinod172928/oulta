import 'package:flutter/material.dart';
import 'package:oulta/features/achivements/badge_model.dart';

import '../../common/widgets/custom_app_bar.dart';

class BadgeDetailsPage extends StatelessWidget {
  final BadgeItem badge;

  const BadgeDetailsPage({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final badgeCircleSize = screenWidth < 400 ? 180.0 : 220.0;

    return Scaffold(
      appBar: CustomAppBar(title: badge.title),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Tagline at very top
              Text(
                badge.subtitle,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Badge Title
              Text(
                badge.title,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // 2. Large badge logo
              Container(
                width: badgeCircleSize,
                height: badgeCircleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        badge.unlocked ? 0.08 : 0.02,
                      ),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Opacity(
                    opacity: badge.unlocked ? 1.0 : 0.4,
                    child: Image.asset(
                      badge.unlocked
                          ? badge.imageAsset
                          : 'assets/badges/default_badge.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // 3. About section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              // 4. Progress/Unlock
              if (badge.unlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'UNLOCKED',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.green[700],
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                )
              else
                _buildProgressInfo(badge),
              const Spacer(),
              // 5. Footer: supply info
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${badge.numberAwarded} / ${badge.totalAvailable} AWARDED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressInfo(BadgeItem badge) {
    return Column(
      children: [
        Text(
          '${badge.progress} of ${badge.goal} completed',
          style: const TextStyle(fontSize: 14.2, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 7),
        SizedBox(
          width: 140,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: badge.progressFraction,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              color: Colors.deepPurple,
            ),
          ),
        ),
      ],
    );
  }
}
