import 'package:flutter/material.dart';

import 'widgets/hero_section.dart';
import 'widgets/impactism_definition_section.dart';
import 'widgets/footer.dart';
import 'widgets/story_components.dart';

import 'widgets/custom_cursor.dart';

class OultaWebHome extends StatelessWidget {
  const OultaWebHome({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCursorWrapper(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
            children: const [
              // 01. Hook (Black)
              AnimatedStorySection(
                step: '01',
                isFirst: true,
                themeColor: Colors.black,
                contentColor: Colors.white,
                child: HeroSection(),
              ),

              // 02. The Definition (White)
              AnimatedStorySection(
                step: '02',
                isLast: true,
                themeColor: Colors.white,
                contentColor: Colors.black,
                child: ImpactismDefinitionSection(),
              ),

              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}
