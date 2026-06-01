import 'package:flutter/material.dart';
import 'package:oulta/features/presentation/account/view/account_page.dart';
import 'package:oulta/features/home/feed_screen.dart';
import 'package:oulta/features/home/oulta_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Start on Oulta center tab (Explore/Feed)

  late final List<Widget> _pages = [
    FeedScreen(),
    const OultaScreen(), // Index 0: Oulta (Left)
    const AccountScreen(), // Index 2: Account (Right)
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItemColumn(
                icon: Icons.explore,
                activeIcon: Icons.explore,
                index: 0,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                label: 'Explore',
              ),
              _CenterNavItemBW(
                index: 1,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
              _NavItemColumn(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                index: 2,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemColumn extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;
  final String label;

  const _NavItemColumn({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentIndex;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 26,
              color: isActive
                  ? Colors.black
                  : Colors.black.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? Colors.black
                    : Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterNavItemBW extends StatelessWidget {
  final int index;
  final int currentIndex;
  final void Function(int) onTap;

  const _CenterNavItemBW({
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64, // Fixed larger size
        height: 64, // Fixed larger size
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.black : Colors.white,
          border: isActive
              ? null
              : Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isActive ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            isActive
                ? 'assets/app_icon/app_icon_white.png'
                : 'assets/app_icon/app_icon_black.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
