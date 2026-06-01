import 'package:flutter/material.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';
import 'package:oulta/features/impact_news/models/impact_news_item.dart';

import 'package:oulta/features/impact_news/widgets/impact_news_card.dart';

class ImpactNewsFullFeed extends StatefulWidget {
  const ImpactNewsFullFeed({Key? key}) : super(key: key);

  @override
  State<ImpactNewsFullFeed> createState() => _ImpactNewsFullFeedState();
}

class _ImpactNewsFullFeedState extends State<ImpactNewsFullFeed> {
  final List<ImpactNewsItem> _newsItems = [
    ImpactNewsItem(
      id: '1',
      title: 'Become an Impactist',
      description: '',
      imageUrl: '', // No image needed
      source: 'Oulta',
      timeAgo: 'Guide',
      bulletPoints: [
        "Choose action over opinion",
        "Focus on real-world outcomes, not arguments",
        "Contribute to society through measurable impact",
        "Collaborate beyond ideology or identity",
        "Be part of rebuilding India through responsibility",
      ],
      likes: 0,
      comments: 0,
    ),
    ImpactNewsItem(
      id: '2',
      title: 'What Is Impactism?',
      description: '',
      imageUrl: '',
      source: 'Oulta',
      timeAgo: 'Concept',
      bulletPoints: [
        "A human-centric framework for progress",
        "Prioritizes real impact over ideology",
        "Aligns welfare and innovation instead of choosing sides",
        "Values accountability, collaboration, and results",
        "Designed for long-term societal growth",
      ],
      likes: 0,
      comments: 0,
    ),
    ImpactNewsItem(
      id: '3',
      title: 'What Impactism Can Do',
      description: '',
      imageUrl: '',
      source: 'Oulta',
      timeAgo: 'Vision',
      bulletPoints: [
        "Rebuild India through real, accountable action",
        "Reduce division by focusing on shared outcomes",
        "Encourage innovation that serves human welfare",
        "Turn communities into action-driven networks",
        "Enable collaboration between people and institutions",
      ],
      likes: 0,
      comments: 0,
    ),
    ImpactNewsItem(
      id: '4',
      title: 'Universal Basic Impact',
      description: '',
      imageUrl: '',
      source: 'Oulta',
      timeAgo: 'Future',
      bulletPoints: [
        "Recognizes and rewards real human contribution",
        "Links recognition and opportunity to action",
        "Goes beyond Universal Basic Income by measuring impact",
        "Encourages meaningful participation, not passive support",
        "Keeps contribution valuable in a changing world",
      ],
      likes: 0,
      comments: 0,
    ),
    ImpactNewsItem(
      id: '5',
      title: 'AI Threats & the Human Future',
      description: '',
      imageUrl: '',
      source: 'Oulta',
      timeAgo: 'Reality',
      bulletPoints: [
        "AI will automate tasks and scale intelligence",
        "Human contribution risks becoming invisible",
        "Impactism keeps humans relevant and valued",
        "Rewards actions AI cannot replace",
        "Promotes Human + AI collaboration, not competition",
        "Shifts society from consumption to contribution",
      ],
      likes: 0,
      comments: 0,
    ),
  ];

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .black, // Dark background for immersive feel? Or White? Let's go White as per image req.
      // Actually image showed a white card on white/grey bg.
      appBar: CustomAppBar(
        title: "IMPACT FEED",
        hasActionButton: false,
        hasLeadingButton: true,
      ),
      body: PageView.builder(
        controller: _pageController,

        // User asked for "slide to left or right" then "route to another page and at that page we... got to next page"
        // Usually "Next Page" in news apps is Vertical or Horizontal.
        // If the user strictly meant "Slide Left/Right" to nav, we should use Horizontal.
        // Let's use Horizontal for "Cards" feel.
        // scrollDirection: Axis.horizontal,

        // Wait, "slide each page and could got to next page".
        // Let's do Vertical for the "Immersive Feed" standard (easier to read bullet points without scrolling inside the card).
        // If I make it Horizontal, the user has to scroll down inside the card?
        // The card fits the screen.
        // Let's stick to Vertical for the main feed, it's safer for "Feed" UX.
        // BUT user said "slide to left show the next". I will follow that instruction strictly.
        scrollDirection: Axis.horizontal,

        itemCount: _newsItems.length,
        itemBuilder: (context, index) {
          final item = _newsItems[index];
          return Container(
            color: Colors.white, // Background of the page
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20,
                ),
                child: Center(
                  child: AspectRatio(
                    aspectRatio:
                        9 / 16, // Approximate phone screen ratio, or just fill
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.85,
                      child: ImpactNewsCard(
                        item: item,
                        onTap: null, // No navigation needed
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
