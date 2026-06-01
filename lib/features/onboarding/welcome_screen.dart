import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oulta/common/routes/routename.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome', true);
    Get.offAllNamed(RouteName.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with logo + skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  const Text(
                    'OULTA',
                    style: TextStyle(
                      fontFamily: 'Serif', // Classic touch
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: const [
                  _WelcomePage(
                    titleTop: 'Impact,',
                    titleBottom: 'Made Simple.',
                    description:
                        'Discover causes, NGOs and people who are rebuilding India and the world.',
                    icon: Icons.favorite_border,
                  ),
                  _WelcomePage(
                    titleTop: 'One Feed,',
                    titleBottom: 'Many Voices.',
                    description:
                        'Follow Impactists, NGOs and campaigns that match your values.',
                    icon: Icons.search_rounded,
                  ),
                  _WelcomePage(
                    titleTop: 'Turn Clicks',
                    titleBottom: 'Into Action.',
                    description:
                        'Earn dharma, unlock badges and see your real-world impact grow.',
                    icon: Icons.bolt_outlined,
                  ),
                ],
              ),
            ),

            _buildControls(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Elegant minimal dots
          Row(
            children: List.generate(3, (index) {
              final isActive = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 4, // Slimmer lines
                width: isActive ? 24 : 12,
                decoration: BoxDecoration(
                  color: isActive ? Colors.black : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),

          // Classic generic button (Sharp corners or pill)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0), // Sharp classic edges
              ),
            ),
            onPressed: () {
              if (_currentPage < 2) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutQuart,
                );
              } else {
                _completeOnboarding();
              }
            },
            child: Text(
              _currentPage == 2 ? 'GET STARTED' : 'NEXT',
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final String titleTop;
  final String titleBottom;
  final String description;
  final IconData icon;

  const _WelcomePage({
    required this.titleTop,
    required this.titleBottom,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          // Icon Area - Minimalist
          Container(
            height: 120,
            width: 120,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12, width: 1),
            ),
            child: Center(child: Icon(icon, size: 48, color: Colors.black)),
          ),
          const Spacer(flex: 1),

          // Typography - Editorial / Classic
          Text(
            titleTop,
            style: const TextStyle(
              fontFamily: 'Serif',
              fontSize: 42,
              height: 1.1,
              fontWeight: FontWeight.w400, // Lighter, more elegant
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            titleBottom,
            style: const TextStyle(
              fontFamily: 'Serif',
              fontSize: 42,
              height: 1.1,
              fontWeight: FontWeight.w400,
              color: Colors.black, // Monochromatic
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black54,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
