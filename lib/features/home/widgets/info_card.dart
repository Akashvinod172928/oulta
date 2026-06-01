import 'package:flutter/material.dart';
import 'package:oulta/features/home/widgets/project_card.dart';

class InfoCard extends StatelessWidget {
  final String heading;
  final String description;
  final Color backgroundColor;
  final List<Project> projects;
  final Function(Project) onProjectTap;

  const InfoCard({
    Key? key,
    required this.heading,
    required this.description,
    this.backgroundColor = Colors.white,
    this.projects = const [],
    required this.onProjectTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: backgroundColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[800],
                height: 1.5,
                fontSize: 16,
              ),
            ),
            if (projects.isNotEmpty) ...[
              const SizedBox(height: 24),
              Divider(thickness: 1, color: Colors.grey[300]),
              const SizedBox(height: 12),
              ListView.separated(
                itemCount: projects.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return _ProjectListCard(
                    project: project,
                    onProjectTap: () => onProjectTap(project),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectListCard extends StatelessWidget {
  final Project project;
  final VoidCallback onProjectTap;
  const _ProjectListCard({required this.project, required this.onProjectTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onProjectTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],                       // Noticeably pleasant grey
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  project.imageAsset,
                  height: 56,
                  width: 56,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.shortDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
