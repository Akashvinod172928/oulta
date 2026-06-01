import 'package:flutter/material.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';
import 'package:oulta/features/home/widgets/info_card.dart';
import 'package:oulta/features/home/widgets/project_card.dart';

class AboutOultaPage extends StatelessWidget {
  const AboutOultaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'About Oulta',
      ),
      body: ListView(
        children: [
          InfoCard(
            heading: 'About OULTA',
            description: '• A global system to help humanity thrive in the age of AI.\n• Redefines value from wealth to human goodness.\n• Measures and amplifies positive impact via a transparent network.',
            projects: const <Project>[],
            onProjectTap: (_) {},
          ),
          InfoCard(
            heading: 'Why the World Needs OULTA',
            description: '• AI is transforming our world, risking human meaning.\n• Makes human kindness and empathy our most valuable currency.\n• Gives every person a way to matter through their contributions.',
            projects: const <Project>[],
            onProjectTap: (_) {},
          ),
          InfoCard(
            heading: 'Our Mission',
            description: '• Empower every person to turn kindness into measurable impact.\n• Connect people, brands, and communities in a transparent network.\n• Replace competition with collaboration and charity with contribution.\n• Build an economy based on Dharma, purpose, and trust.',
            projects: const <Project>[],
            onProjectTap: (_) {},
          ),
          InfoCard(
            heading: 'Our Vision',
            description: '• A world where impact replaces income as the measure of value.\n• A Universal Basic Impact (UBI) system that rewards contribution.\n• A society that celebrates every verified act of good.\n• A civilization based on shared purpose and universal responsibility.',
            projects: const <Project>[],
            onProjectTap: (_) {},
          ),
          InfoCard(
            heading: 'OULTA Vision Components (OVC)',
            description: '• Human Dignity as Data: Good acts become proof of human worth.\n• Ethical AI Collaboration: AI handles efficiency, humans bring empathy.\n• Collective Dharma Economy: A value system that rewards contribution.',
            projects: const <Project>[],
            onProjectTap: (_) {},
          ),
          InfoCard(
            heading: 'OULTA Impact Chain (OIC)',
            description: '• A transparent chain that tracks and verifies positive impact.\n• Ensures every contribution is visible and traceable.\n• Links every Dharma point to real-world results.',
            projects: const <Project>[],
            onProjectTap: (_) {},
          ),
          InfoCard(
            heading: 'OULTA Social Matrix (OSM)',
            description: '• A living ecosystem where people and organizations create shared value.\n• Powered by people who act, brands that have impact, and communities that collaborate.\n• Turns scattered good deeds into a unified human movement.',
            projects: const <Project>[],
            onProjectTap: (_) {},
          ),
          InfoCard(
            heading: 'Universal Basic Impact (UBI)',
            description: '• A new social framework that rewards every positive human act.\n• Values impact over labor, turning kindness into Dharma points.\n• Ensures no good deed goes unnoticed.',
            projects: const <Project>[],
            onProjectTap: (_) {},
          ),
          InfoCard(
            heading: 'Rebuilding India — The Model Nation',
            description: '• India is the foundation for a compassion-driven civilization.\n• Empowers students, villages, and businesses to grow through purpose.\n• Aims to build a model for a humane, ethical, AI-powered future.',
            projects: const <Project>[],
            onProjectTap: (_) {},
          ),
          InfoCard(
            heading: 'Saving Humanity from AI Impact',
            description: '• Ensures AI reminds us of our uniqueness, rather than replacing us.\n• Creates an economy of purpose that machines cannot replicate.\n• Balances a world where machines produce and humans care.',
            projects: const <Project>[],
            onProjectTap: (_) {},
          ),
        ],
      ),
    );
  }
}
