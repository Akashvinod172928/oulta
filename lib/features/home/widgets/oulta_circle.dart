
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller.dart';
import 'infoCard.dart';

class OultaCircle extends StatelessWidget {
  const OultaCircle({super.key});

  @override
  Widget build(BuildContext context) {
    final CircleController controller = Get.put(CircleController());

    // Info data for each circle
    final Map<String, Map<String, dynamic>> infoData = {
      "OULTA": {
        "heading": "OULTA",
        "description": "OULTA is the main hub. This is dummy text to describe it.OULTA is the main hub. This is dummy text to describe it.OULTA is the main hub. This is dummy text to describe it.OULTA is the main hub. This is dummy text to describe it.OULTA is the main hub. This is dummy text to describe it.OULTA is the main hub. This is dummy text to describe it.OULTA is the main hub. This is dummy text to describe it.",
        "color": Colors.lightBlue.shade50,
      },
      "OSM": {
        "heading": "OSM",
        "description": "OSM description goes here. Dummy placeholder text.",
        "color": Colors.green.shade50,
      },
      "OVC": {
        "heading": "OVC (Oulta Venture Core)",
        "description": "This is a dummy description for OVC services.",
        "color": Colors.yellow.shade50,
      },
      "OIC": {
        "heading": "OIC",
        "description": "OIC details with some short placeholder description.",
        "color": Colors.red.shade50,
      },
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circle group
        Center(
          child: Container(
            width: 330,
            height: 330,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildOultaCircle(controller, "OULTA", isOulta: true),
                Transform.translate(
                  offset: const Offset(0, -100),
                  child: _buildOultaCircle(controller, "OSM"),
                ),
                Transform.translate(
                  offset: const Offset(-80, 60),
                  child: _buildOultaCircle(controller, "OVC"),
                ),
                Transform.translate(
                  offset: const Offset(80, 60),
                  child: _buildOultaCircle(controller, "OIC"),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Show InfoCard for selected circle
        Obx(() {
          if (controller.selectedName.isEmpty) {
            return const SizedBox();
          }

          final data = infoData[controller.selectedName.value]!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InfoCard(
              heading: data["heading"],
              description: data["description"],
              backgroundColor: data["color"],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOultaCircle(CircleController controller, String text,
      {bool isOulta = false}) {
    return GestureDetector(
      onTap: () => controller.selectCircle(text),
      child: Obx(() {
        final bool isSelected = controller.selectedName.value == text;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isOulta ? 100 : 70,
          height: isOulta ? 100 : 70,
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.shade300 : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }),
    );
  }
}

