import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:oulta/features/home/view/project_details_page.dart';
import 'package:oulta/features/home/widgets/project_card.dart';
import 'package:oulta/features/presentation/social/view.dart';
// import 'info_card.dart';

class CircleController extends GetxController {
  var selectedName = "OULTA".obs;
  void selectCircle(String name) => selectedName.value = name;
}

class OultaCircle extends StatelessWidget {
  const OultaCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CircleController controller = Get.put(CircleController());

    final Map<String, Map<String, dynamic>> infoData = {
      "OULTA": {
        "heading": "OULTA",
        "description":
            "OULTA is the main hub—organizing all impact and innovation. Select a department to see its flagship project.",
        "color": Colors.white,
        "projects": <Project>[],
      },
      "OSM": {
        "heading": "OSM PROJECTS",
        "description":
            "Oulta Social Management boosts NGOs and powers cause-driven engagement.",
        "color": Colors.white,
        "projects": <Project>[
          // const Project(
          //   imageAsset: "assets/projects/for_her.png",
          //   name: "For Her",
          //   shortDescription: "An NGO focused on women's health and empowerment.",
          //   longDescription: "For Her is dedicated to providing healthcare and education to women in underserved communities. We run clinics, workshops, and awareness campaigns to promote female hygiene, maternal health, and overall well-being. Our goal is to empower women to lead healthier and more informed lives.",
          //   galleryImages: [],
          //   websiteUrl: 'https://example.com/for-her'
          // ),
        ],
      },
      "OVC": {
        "heading": "OVC PROJECTS",
        "description":
            "Kickstarting for-profit ventures, each fueling our impact engine.",
        "color": Colors.white,
        "projects": <Project>[
          const Project(
            imageAsset: "assets/projects/loserkind.png",
            name: "Loserkind",
            shortDescription: "A fashion venture with a social mission.",
            longDescription:
                "Loserkind is a sustainable fashion brand that creates high-quality apparel from eco-friendly materials. A portion of every sale is donated to environmental conservation projects. We believe that fashion can be a force for good, and our mission is to make style and sustainability accessible to everyone.",
            galleryImages: [],
          ),
          const Project(
            imageAsset: "assets/projects/trust_karo.png",
            name: "Trust Karo",
            shortDescription:
                "A platform that builds real trust between people.",
            longDescription:
                "Trust Karo is a digital trust platform that helps people verify each other, share credible reviews, and build reputation over time. "
                "The goal is simple: make it easier and safer for people to trust one another online and offline.",
            galleryImages: [],
          ),
        ],
      },
      "OIC": {
        "heading": "OIC PROJECTS",
        "description":
            "Championing innovation and young talent for social good.",
        "color": Colors.white,
        "projects": <Project>[
          // const Project(
          //   imageAsset: "assets/projects/kalamshala.png",
          //   name: "Kalamshala",
          //   shortDescription: "An innovation hub for students and young entrepreneurs.",
          //   longDescription: "Kalamshala provides a collaborative space for students and aspiring entrepreneurs to develop their ideas. We offer mentorship, workshops, and access to resources to help turn innovative concepts into real-world solutions. Our focus is on fostering creativity and driving social change through technology and entrepreneurship.",
          //   galleryImages: [],
          // ),
        ],
      },
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /*
        Container(
          width: 330,
          height: 330,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 26,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildOultaCircle(controller, "OULTA", isOulta: true),
              Transform.translate(
                offset: const Offset(0, -104),
                child: _buildOultaCircle(controller, "OSM"),
              ),
              Transform.translate(
                offset: const Offset(-82, 64),
                child: _buildOultaCircle(controller, "OVC"),
              ),
              Transform.translate(
                offset: const Offset(82, 64),
                child: _buildOultaCircle(controller, "OIC"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Obx(() {
          final selected = controller.selectedName.value;
          final data = infoData[selected]!;
          final List<Project> projects = data["projects"] as List<Project>;

          if (selected == "OULTA") {
            return Column(
              children: [
                InfoCard(
                  heading: data["heading"],
                  description: data["description"],
                  backgroundColor: data["color"],
                  projects: projects,
                  onProjectTap: (project) =>
                      Get.to(() => ProjectDetailsPage(project: project)),
                ),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Introducing Impactism",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Impactism is a human-centric framework that unites welfare and innovation by making real, measurable impact the primary driver of societal progress.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // The "Two" Components: Welfare & Innovation
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildConceptPill(
                            icon: Icons.favorite_rounded,
                            label: "Welfare",
                            color: const Color(0xFFFFF1F2), // Soft Rose
                            iconColor: const Color(0xFFE11D48), // Rose Red
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: Colors.grey[400],
                              size: 14,
                            ),
                          ),
                          _buildConceptPill(
                            icon: Icons.lightbulb_rounded,
                            label: "Innovation",
                            color: const Color(0xFFEFF6FF), // Soft Blue
                            iconColor: const Color(0xFF2563EB), // Royal Blue
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Enabling humans and AI to collaborate responsibly in the future.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Becoming an Impactist
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Becoming an Impactist",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Becoming an Impactist means choosing action over opinions and contributing toward real, measurable impact in the world.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "An Impactist believes progress comes from what actually works, not from ideology or arguments. Regardless of political views, Impactists focus on actions that strengthen welfare, innovation, and accountability, and help society move forward.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 3. Universal Basic Impact (UBI²)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Universal Basic Impact (UBI²)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Universal Basic Impact is a system that recognizes and rewards real human contribution rather than passive participation.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Unlike Universal Basic Income, which distributes support without measuring contribution, Universal Basic Impact links recognition and opportunity to real-world actions that create social, civic, or innovative value. It is designed to keep humans relevant and valued in the AI era.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 140),
              ],
            );
          }

          return InfoCard(
            heading: data["heading"],
            description: data["description"],
            backgroundColor: data["color"],
            projects: projects,
            onProjectTap: (project) =>
                Get.to(() => ProjectDetailsPage(project: project)),
          );
        }),
        */

        // Static Impactist Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              _buildImpactistSection("Join as an Impactist", [
                "Joining as an Impactist means choosing action over opinion.",
                "An Impactist is someone who believes real progress comes from what we do, not what we argue about. Regardless of political ideology, background, or profession, Impactists focus on creating measurable, positive impact in society.",
                "By joining as an Impactist, you become part of a community that values responsibility, collaboration, and real-world outcomes — not noise.",
              ]),
              const SizedBox(height: 24),
              _buildImpactistSection("What is Impactism?", [
                "Impactism is a human-centric framework that makes real impact the primary measure of progress.",
                "Instead of rewarding power, money, or popularity, Impactism rewards actions that actually improve lives. It brings together the strengths of existing systems by aligning welfare and innovation, while removing ideological conflict.",
                "Impactism is not about control or belief — it is about accountability, transparency, and results.",
              ]),
              const SizedBox(height: 24),
              _buildImpactistSection(
                "What Impactism Can Do",
                [
                  "Impactism creates a system where impact becomes visible and valuable. It can:",
                ],
                bulletPoints: [
                  "Rebuild India through real, accountable action",
                  "Encourage innovation that serves human welfare",
                  "Reduce conflict by aligning incentives around shared outcomes",
                  "Replace arguments with collaboration",
                  "Turn communities into action networks",
                  "Create long-term progress beyond ideology",
                ],
              ),
              const SizedBox(height: 24),
              _buildImpactistSection("What is Universal Basic Impact (UBI²)?", [
                "Universal Basic Impact is a model that recognizes and rewards real human contribution.",
                "Unlike Universal Basic Income, which distributes support without measuring contribution, Universal Basic Impact links recognition, opportunity, and rewards to real-world actions — social, environmental, civic, or innovative.",
                "Universal Basic Impact ensures that meaningful participation matters, especially in a future where automation replaces routine work.",
              ]),
              const SizedBox(height: 24),
              _buildImpactistSection(
                "How Impactism Tackles AI Threats",
                [
                  "AI will scale intelligence, automate jobs, and concentrate power — but it cannot replace human responsibility, values, and purpose.",
                  "Impactism tackles AI-era risks by:",
                ],
                bulletPoints: [
                  "Keeping humans relevant and valued through impact-based systems",
                  "Rewarding contributions that AI cannot replace",
                  "Aligning human goals with AI tools instead of competing with them",
                  "Shifting society from consumption to contribution",
                  "By combining Human Intelligence and Artificial Intelligence (AHI), Impactism ensures technology serves humanity — not the other way around.",
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /*
  Widget _buildOultaCircle(
    CircleController controller,
    String text, {
    bool isOulta = false,
  }) {
    return GestureDetector(
      onTap: () => controller.selectCircle(text),
      child: Obx(() {
        final bool isSelected = controller.selectedName.value == text;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isOulta ? 108 : 76,
          height: isOulta ? 108 : 76,
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3A3A3A), Colors.black],
                    stops: [0.0, 0.7],
                  )
                : const LinearGradient(colors: [Colors.white, Colors.white]),
            shape: BoxShape.circle,
            border: isSelected ? null : Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.3 : 0.08),
                blurRadius: isSelected ? 25 : 12,
                offset: isSelected ? const Offset(5, 10) : const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: isOulta ? 22 : 16,
                letterSpacing: 0.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildConceptPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
*/
  Widget _buildImpactistSection(
    String title,
    List<String> paragraphs, {
    List<String>? bulletPoints,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...paragraphs.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          if (bulletPoints != null) ...[
            const SizedBox(height: 4),
            ...bulletPoints.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "•  ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
