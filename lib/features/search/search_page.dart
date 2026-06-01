import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/profile/view/user_profile_page.dart';
import 'package:oulta/features/search/search_controller.dart';
import '../../common/routes/routename.dart';
import '../../common/widgets/custom_app_bar.dart';
import 'package:oulta/common/widgets/universal_image.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensuring the controller is initialized
    final UserSearchController controller = Get.isRegistered<UserSearchController>() 
        ? Get.find<UserSearchController>() 
        : Get.put(UserSearchController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'SEARCH',
        onTrailingIconPressed: () => Get.toNamed(RouteName.settings),
      ),
      body: Column(
        children: [
          _SearchBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!controller.hasSearched.value) {
                return const _EmptyState(
                  icon: Icons.search,
                  title: 'Search Oulta',
                  subtitle:
                      'Find people, NGOs, and communities to connect with.',
                );
              }

              if (controller.searchResults.isEmpty) {
                return const _EmptyState(
                  icon: Icons.sentiment_dissatisfied,
                  title: 'No Results Found',
                  subtitle:
                      'We couldn\'t find any users matching your search. Please try a different name.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: controller.searchResults.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = controller.searchResults[index];
                  final userData = user.data() as Map<String, dynamic>;
                  final profileType = (userData['profileType'] ?? 'user') as String;
                  final isNgo = profileType == 'ngo';
                  final isCompany = profileType == 'company';
                  
                  // Use ngoName for NGOs, companyName for companies, otherwise 'name'
                  final displayName = isNgo
                      ? ((userData['ngoName'] ?? userData['name'] ?? '') as String)
                      : (isCompany 
                          ? ((userData['companyName'] ?? userData['name'] ?? '') as String)
                          : ((userData['name'] ?? '') as String));

                  final photoUrl = isNgo 
                      ? (userData['ngoLogo'] ?? userData['photoUrl'] ?? '') as String
                      : (isCompany
                          ? (userData['companyLogo'] ?? userData['photoUrl'] ?? '') as String
                          : (userData['photoUrl'] ?? '') as String);

                  // Using tagline, industry or handle as subtitle.
                  final subtitle = (userData['tagline'] ?? '').isNotEmpty
                      ? (userData['tagline'] as String)
                      : (isCompany
                          ? ((userData['companyIndustry'] ?? userData['csrDetails'] ?? '').isNotEmpty
                              ? (userData['companyIndustry'] ?? userData['csrDetails'] ?? '') as String
                              : '@${(userData['name_lowercase'] ?? userData['name'] ?? '').toString().replaceAll(' ', '').toLowerCase()}')
                          : '@${(userData['name_lowercase'] ?? userData['name'] ?? '').toString().replaceAll(' ', '').toLowerCase()}');

                  // user.id is the Firestore document ID — pass it to bypass name-based lookup
                  final username = (userData['name'] ?? displayName).toString().trim();
                  final docId = user.id;
                  return _UserResultTile(
                    name: displayName,
                    photoUrl: photoUrl,
                    subtitle: subtitle,
                    profileType: profileType,
                    onTap: () => Get.to(
                      () => UserProfilePage(
                        username: username,
                        userId: docId,
                      ),
                      transition: Transition.rightToLeft,
                    ),
                  );

                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final UserSearchController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Colors.grey, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.textEditingController,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search people, NGOs, companies...',
                  hintStyle: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) => controller.searchUsers(value),
              ),
            ),
            Obx(() => controller.query.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    controller.clearSearch();
                  },
                )
              : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserResultTile extends StatelessWidget {
  final String name;
  final String photoUrl;
  final String? subtitle;
  final String profileType;
  final VoidCallback onTap;

  const _UserResultTile({
    required this.name,
    required this.photoUrl,
    this.subtitle,
    required this.profileType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNgo = profileType == 'ngo';
    final isCompany = profileType == 'company';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isNgo 
                          ? Colors.blue.shade100 
                          : (isCompany ? Colors.teal.shade100 : Colors.transparent),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: photoUrl.isNotEmpty
                        ? getUniversalImageProvider(photoUrl)
                        : null,
                    onBackgroundImageError: photoUrl.isNotEmpty
                        ? (exception, stackTrace) {
                            // Silently handle web image decoding/CORS errors
                          }
                        : null,
                    child: photoUrl.isEmpty
                        ? Icon(
                            isNgo 
                                ? Icons.business_rounded 
                                : (isCompany ? Icons.domain_rounded : Icons.person_rounded),
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isNgo 
                                  ? Colors.blue.shade50 
                                  : (isCompany ? Colors.teal.shade50 : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              profileType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isNgo 
                                    ? Colors.blue.shade700 
                                    : (isCompany ? Colors.teal.shade700 : Colors.grey.shade600),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
