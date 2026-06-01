import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/impact_news/view/impact_news_full_feed.dart';

class ImpactNewsFeedSection extends StatefulWidget {
  const ImpactNewsFeedSection({Key? key}) : super(key: key);

  @override
  State<ImpactNewsFeedSection> createState() => _ImpactNewsFeedSectionState();
}

class _ImpactNewsFeedSectionState extends State<ImpactNewsFeedSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Luxury Heading
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BECOME AS AN",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: Colors.grey,
                ),
              ),
              Text(
                "IMPACTIST",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -1,
                  fontFamily: 'Serif',
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),

        // The Interactable Stack
        GestureDetector(
          onTap: () {
            // Navigate to the full immersive feed
            Get.to(() => const ImpactNewsFullFeed());
          },
          onHorizontalDragEnd: (details) {
            // Also navigate on swipe
            Get.to(() => const ImpactNewsFullFeed());
          },
          child: Container(
            height: 480, // Increased height
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 45),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Card 2 (Smallest, furthest back)
                _buildStackCard(
                  offset: const Offset(50, 0), // Increased offset to right
                  scale: 0.85,
                  rotation: 0.12, // Increased rotation
                  opacity: 0.5,
                  color: const Color(0xFFC4D7E0),
                ),
                // Background Card 1 (Middle)
                _buildStackCard(
                  offset: const Offset(25, 0), // Increased offset to right
                  scale: 0.92,
                  rotation: 0.06, // Increased rotation
                  opacity: 0.8,
                  color: const Color(0xFFE8F1F5),
                ),
                // Foreground Card (Main)
                _buildMainCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStackCard({
    required Offset offset,
    required double scale,
    required double rotation,
    required double opacity,
    required Color color,
  }) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Content
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Not Everyone Will Get It — And That’s Okay",
                    style: TextStyle(
                      fontSize: 26, // Reduced font size
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Serif',
                      height: 1.1,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Impactism speaks to those ready to think beyond opinions and act with purpose. Change has always started with a conscious 10% before it reached the many.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Row(
                    children: [
                      Text(
                        "Tap to explore",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // "Tap to Open" Overlay Indicator
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Get.to(() => const ImpactNewsFullFeed()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
