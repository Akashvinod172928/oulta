import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/widgets/custom_app_bar.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Premium light background
      appBar: const CustomAppBar(
        title: 'Power Impactism',
        hasActionButton: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF111111), Color(0xFF1C1C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000), // Slightly stronger dark shadow
                      blurRadius: 32,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Why Power Impactism?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Impactism is an Anti-Imperialist Movement.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4AF37), // Premium Gold accent
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'We reject today’s endless wars, exploitation, and great-power domination.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 44),

              // Cards
              _buildTierCard(
                title: 'Origin Impactist',
                price: '₹149',
                description: 'Where your impact journey begins',
                color: const Color(0xFFC0C0C0), // Premium Silver
                isPrime: false,
                buttonFilled: true,
                imageAsset: 'assets/badges/Black Illustrated Glasses Logo (4).png',
                onTap: () => _launchUrl('https://rzp.io/rzp/r1Grm2e'),
              ),
              const SizedBox(height: 24),
              
              _buildTierCard(
                title: 'Prime Impactist',
                price: '₹349',
                description: 'Driving real and consistent impact',
                color: const Color(0xFFD4AF37), // Gold
                isPrime: true,
                buttonFilled: true,
                imageAsset: 'assets/badges/Black Illustrated Glasses Logo (2).png',
                onTap: () => _launchUrl('https://rzp.io/rzp/RkD3JKeW'),
              ),
              const SizedBox(height: 24),

              _buildTierCard(
                title: 'Eternal Impactist',
                price: '₹899',
                description: 'Creating lasting impact beyond time',
                color: const Color(0xFF4B2E83), // Quality deep purple
                isPrime: false,
                buttonFilled: true,
                imageAsset: 'assets/badges/Black Illustrated Glasses Logo (7).png',
                onTap: () => _launchUrl('https://rzp.io/rzp/1BMlXr2t'),
              ),

              const SizedBox(height: 40),
              
              // Rest of the points section
              _buildWhySection(),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhySection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // very soft shadow
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWhyItem(
            '1. Make Impact Visible',
            'Every action is tracked, measured, and rewarded with full transparency.',
            Icons.visibility_rounded,
          ),
          _buildWhyItem(
            '2. Create a New Value System',
            'Move beyond wealth and status. Your worth is now defined by the real impact you create.',
            Icons.star_rounded,
          ),
          _buildWhyItem(
            '3. Fuel Real Change',
            'Directly support education, welfare, and innovation that truly improve lives.',
            Icons.bolt_rounded,
          ),
          _buildWhyItem(
            '4. Return Power to People',
            'Shift control from centralized systems to individuals and communities who create value.',
            Icons.people_alt_rounded,
          ),
          _buildWhyItem(
            '5. Build a Lasting Future',
            'You’re not just contributing — you’re helping create a better system that endures for generations.',
            Icons.account_balance_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildWhyItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.black54,
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required String title,
    required String price,
    required String description,
    required Color color,
    Color? baseColor,
    required bool isPrime,
    required bool buttonFilled,
    String? imageAsset,
    required VoidCallback onTap,
  }) {
    final double scale = isPrime ? 1.05 : 1.0;
    final Color effectColor = baseColor ?? color;
    
    // Determine button text color for filled buttons (dark for light backgrounds like gold, white for dark backgrounds like purple)
    final Color filledButtonTextColor = effectColor.computeLuminance() > 0.4 ? Colors.black87 : Colors.white;

    return Padding(
      // Add padding to avoid clipping the box shadow scaled out
      padding: EdgeInsets.symmetric(horizontal: isPrime ? 8.0 : 0.0),
      child: Transform.scale(
        scale: scale,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPrime ? effectColor.withOpacity(0.5) : Colors.grey.shade200,
              width: isPrime ? 1.5 : 1,
            ),
            boxShadow: isPrime
                ? [
                    BoxShadow(
                      color: effectColor.withOpacity(0.2),
                      blurRadius: 32,
                      spreadRadius: 2,
                      offset: const Offset(0, 12),
                    )
                  ]
                : [
                    const BoxShadow(
                      color: Color(0x0A000000), // very soft black shadow
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPrime) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: effectColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: effectColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: effectColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Most Chosen',
                        style: TextStyle(
                          color: effectColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon badge representation
                  Container(
                    padding: EdgeInsets.all(imageAsset != null ? 6 : 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: effectColor.withOpacity(0.1),
                      border: Border.all(color: effectColor.withOpacity(0.2)),
                    ),
                    child: imageAsset != null
                        ? Image.asset(imageAsset, width: 46, height: 46, fit: BoxFit.contain)
                        : Icon(Icons.fingerprint_rounded, color: color, size: 28),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: isPrime ? 22 : 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6.0, left: 6.0),
                    child: Text(
                      '/ month',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonFilled ? effectColor : Colors.transparent,
                    foregroundColor: buttonFilled ? filledButtonTextColor : effectColor,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: buttonFilled
                          ? BorderSide.none
                          : BorderSide(color: effectColor.withOpacity(0.6), width: 1.5),
                    ),
                  ),
                  child: Text(
                    'Be Part of It',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: buttonFilled ? filledButtonTextColor : effectColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
