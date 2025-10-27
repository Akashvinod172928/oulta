import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class OultaWebHome extends StatelessWidget {
  const OultaWebHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _NavBar(),
            _HeroSection(),
            _ProblemSection(),
            _AboutSection(),
            _EcosystemSection(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 40,
          vertical: 20
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const OultaWebHome()),
                  );
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/app_icon/appicon.png',
                      width: 40,  // Adjust width as needed
                      height: 40, // Adjust height as needed
                      fit: BoxFit.contain, // Adjust fit as needed
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "OULTA",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: 1.5,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isMobile)
            Row(
              children: const [
                _NavButton(title: "Home"),
                _NavButton(title: "About"),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                // Show mobile menu
                Scaffold.of(context).openEndDrawer();
              },
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final String title;
  const _NavButton({required this.title});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: TextButton(
          onPressed: () {
            // Navigate to the appropriate page
            switch (widget.title) {
              case "Home":
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const OultaWebHome()),
                );
                break;
              case "About":
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
                break;

            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _isHovered ? Colors.black : Colors.transparent,
                  width: 2.0,
                ),
              ),
            ),
            child: Text(
              widget.title.toUpperCase(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 60 : 80,
          horizontal: isMobile ? 20 : 24
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedText(
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 32 : 42,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.3,
              letterSpacing: -0.5,
            ),
            text: "Rebuilding India Through Impact",
          ),
          const SizedBox(height: 20),
          Text(
            "Oulta is a social media platform for social impact — connecting citizens, NGOs, and companies to collaborate and rebuild the nation through innovation and purpose.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: isMobile ? 16 : 17,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     _AnimatedButton(
          //       text: "Join the Movement",
          //       isPrimary: true,
          //       onPressed: () {
          //         // Navigate to sign up page
          //       },
          //     ),
          //     const SizedBox(width: 16),
          //     _AnimatedButton(
          //       text: "Become a Client",
          //       isPrimary: false,
          //       onPressed: () {
          //         Navigator.of(context).push(
          //           MaterialPageRoute(builder: (context) => const ClientFormPage()),
          //         );
          //       },
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _AnimatedButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.isPrimary
                ? ElevatedButton(
              onPressed: () {
                _controller.forward().then((_) {
                  _controller.reverse();
                  widget.onPressed();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _isHovered ? 8 : 2,
              ),
              child: Text(
                widget.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
                : OutlinedButton(
              onPressed: () {
                _controller.forward().then((_) {
                  _controller.reverse();
                  widget.onPressed();
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _isHovered ? 8 : 0,
              ),
              child: Text(
                widget.text,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProblemSection extends StatelessWidget {
  const _ProblemSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 60 : 80,
          horizontal: isMobile ? 20 : 24
      ),
      child: Column(
        children: [
          const Text(
            "The Challenge",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "AI and automation are changing the world faster than ever. While technology becomes cheaper, inequality keeps growing. "
                "Oulta exists to bridge that gap — creating one shared space where citizens, innovators, and NGOs can act together to make real impact.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white70,
                fontSize: isMobile ? 15 : 16,
                height: 1.6
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 60 : 80,
          horizontal: isMobile ? 20 : 24
      ),
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        children: [
          const Text(
            "What is Oulta?",
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Oulta is the world's first Universal Basic Impact network — a new kind of social media where every post, project, and idea contributes to real change. "
                "It's a black-and-white space — transparent, simple, and built for collaboration. Oulta transforms social networking into a tool for national rebuilding.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black54,
                fontSize: isMobile ? 15 : 16,
                height: 1.6
            ),
          ),
        ],
      ),
    );
  }
}

class _EcosystemSection extends StatelessWidget {
  const _EcosystemSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 60 : 80,
          horizontal: isMobile ? 20 : 24
      ),
      child: Column(
        children: [
          const Text(
            "The Oulta Ecosystem",
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _EcosystemCard(
            title: "OVC — Oulta Venture Core",
            desc: "Builds new-age companies that generate profits to fund social good and innovation.",
            isMobile: isMobile,
          ),
          const SizedBox(height: 16),
          _EcosystemCard(
            title: "OIC — Oulta Innovation Core",
            desc: "Encourages creators and innovators to turn ideas into technology-driven impact projects.",
            isMobile: isMobile,
          ),
          const SizedBox(height: 16),
          _EcosystemCard(
            title: "OSM — Oulta Social Management",
            desc: "Empowers NGOs and social causes with visibility, partnerships, and long-term sustainability.",
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }
}

class _EcosystemCard extends StatefulWidget {
  final String title;
  final String desc;
  final bool isMobile;

  const _EcosystemCard({
    required this.title,
    required this.desc,
    required this.isMobile,
  });

  @override
  State<_EcosystemCard> createState() => _EcosystemCardState();
}

class _EcosystemCardState extends State<_EcosystemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: Container(
              width: widget.isMobile ? double.infinity : 600,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(_isHovered ? 0.15 : 0.05),
                    blurRadius: _isHovered ? 15 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.desc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            "OULTA",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "© 2025 Oulta. All rights reserved.",
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.link, color: Colors.white60),
                onPressed: () async {
                  const url = 'https://example.com';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.email, color: Colors.white60),
                onPressed: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'contact@oulta.com',
                  );
                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: Colors.white60),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AdminPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AnimatedText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign,
  }) : super(key: key);

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Text(
        widget.text,
        style: widget.style,
        textAlign: widget.textAlign,
      ),
    );
  }
}

// New About Page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const _NavBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 60 : 80,
                horizontal: isMobile ? 20 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedText(
                    text: "About Oulta",
                    style: TextStyle(
                      fontSize: isMobile ? 32 : 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Our Mission",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Oulta is on a mission to rebuild India through impact. We believe that when citizens, NGOs, and companies collaborate, we can solve the most pressing challenges facing our nation. Our platform connects people with purpose, turning social media into a tool for real change.",
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Our Story",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Founded in 2023, Oulta emerged from a simple observation: while technology was advancing rapidly, social inequality was growing. Our founders envisioned a platform where technology could be harnessed for social good, creating a new model of social media focused on impact rather than engagement metrics.",
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Our Values",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ValueCard(
                    title: "Transparency",
                    description: "We believe in complete transparency in all our operations and partnerships.",
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 16),
                  _ValueCard(
                    title: "Collaboration",
                    description: "We foster collaboration between citizens, NGOs, and companies for maximum impact.",
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 16),
                  _ValueCard(
                    title: "Innovation",
                    description: "We embrace innovative solutions to address complex social challenges.",
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 16),
                  _ValueCard(
                    title: "Impact",
                    description: "We measure our success by the real-world impact we create in communities.",
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Our Team",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Our diverse team brings together experts from technology, social work, business, and design. United by our passion for social impact, we work tirelessly to build a platform that empowers everyone to contribute to rebuilding India.",
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Center(
                  //   child: _AnimatedButton(
                  //     text: "Become a Client",
                  //     isPrimary: true,
                  //     onPressed: () {
                  //       Navigator.of(context).push(
                  //         MaterialPageRoute(builder: (context) => const ClientFormPage()),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isMobile;

  const _ValueCard({
    required this.title,
    required this.description,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Client Form Page - where clients can enter their details


// Admin Page to view client details
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // List to store client details (in memory only)
  List<Map<String, String>> clients = [];

  void _addClient(Map<String, String> clientData) {
    setState(() {
      clients.add(clientData);
    });
  }

  void _clearAllClients() {
    setState(() {
      clients.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Client Details", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Clear All Clients"),
                  content: const Text("Are you sure you want to clear all client details?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _clearAllClients();
                      },
                      child: const Text("Clear All"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: clients.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              "No client details yet",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        client['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            clients.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow("Company:", client['company'] ?? ''),
                  _buildDetailRow("Email:", client['email'] ?? ''),
                  _buildDetailRow("Phone:", client['phone'] ?? ''),
                  _buildDetailRow("Project:", client['project'] ?? ''),
                  _buildDetailRow("Message:", client['message'] ?? ''),
                  _buildDetailRow("Date:", client['date'] ?? ''),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
