import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oulta/common/widgets/universal_image.dart';
import 'package:oulta/features/presentation/social/controller/social_controller.dart';
import 'package:oulta/features/presentation/social/widgets/impact_stand_card.dart';

class EditImpactStandScreen extends StatefulWidget {
  final ImpactStand impactStand;
  const EditImpactStandScreen({Key? key, required this.impactStand})
    : super(key: key);

  @override
  State<EditImpactStandScreen> createState() => _EditImpactStandScreenState();
}

class _EditImpactStandScreenState extends State<EditImpactStandScreen> {
  late final TextEditingController nameController;
  late final TextEditingController subHeadingController;
  late final TextEditingController descriptionController;
  late final RxList<Map<String, String>> whoShouldActList;
  final TextEditingController actorNameController = TextEditingController();
  final TextEditingController actorAuthorityController =
      TextEditingController();
  late final RxList<dynamic> imageFiles;
  final ImagePicker _picker = ImagePicker();
  late final RxString selectedCommunity;
  late final RxString selectedType;
  late final RxBool isPetition;

  final List<String> impactStandTypes = [
    'Education',
    'Healthcare',
    'Women Empowerment',
    'Environment',
    'Workplace Dignity'
  ];

  final Map<String, String> communityMap = {
    'india': 'India',
    'kerala': 'Kerala',
  };

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.impactStand.name);
    subHeadingController = TextEditingController(
      text: widget.impactStand.subHeading,
    );
    descriptionController = TextEditingController(
      text: widget.impactStand.description,
    );
    whoShouldActList = widget.impactStand.whoShouldAct
        .map((e) => Map<String, String>.from(e))
        .toList()
        .obs;
    imageFiles = <dynamic>[...widget.impactStand.photoUrls].obs;
    selectedCommunity = widget.impactStand.community.obs;
    selectedType = widget.impactStand.type.obs;
    isPetition = widget.impactStand.isPetition.obs;
  }

  @override
  void dispose() {
    nameController.dispose();
    subHeadingController.dispose();
    descriptionController.dispose();
    actorNameController.dispose();
    actorAuthorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SocialController socialController = Get.find<SocialController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Impact Stand',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stand Name (Heading)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: _inputDecoration('Enter name or heading'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sub-heading',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: subHeadingController,
              decoration: _inputDecoration('Enter a short tagline'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: _inputDecoration('Enter full description'),
              maxLines: 5,
            ),
            const SizedBox(height: 24),

            const Text(
              'Select Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType.value,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: impactStandTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        selectedType.value = newValue;
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Stand Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildActionTypeCard(
                      title: 'Impact Stand',
                      subtitle: 'Take a stand on an issue',
                      icon: Icons.flag_rounded,
                      isSelected: !isPetition.value,
                      onTap: () => isPetition.value = false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionTypeCard(
                      title: 'Petition',
                      subtitle: 'Sign to demand change',
                      icon: Icons.assignment_turned_in_rounded,
                      isSelected: isPetition.value,
                      onTap: () => isPetition.value = true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Photos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final List<XFile> pickedFiles = await _picker
                        .pickMultiImage(imageQuality: 70, maxWidth: 1024);
                    if (pickedFiles.isNotEmpty) {
                      imageFiles.addAll(pickedFiles);
                    }
                  },
                  icon: const Icon(Icons.add_a_photo, color: Colors.black),
                  label: const Text(
                    'Add Photos',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Photos Preview List
            Obx(
              () => imageFiles.isEmpty
                  ? Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No photos',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageFiles.length,
                        itemBuilder: (context, index) {
                          final item = imageFiles[index];
                          return Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildImagePreview(item),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: GestureDetector(
                                    onTap: () => imageFiles.removeAt(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Who Should Act (Authority List)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: actorNameController,
                        decoration: _inputDecoration('Name/Agency'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: actorAuthorityController,
                        decoration: _inputDecoration('Authority/Role'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: () {
                    if (actorNameController.text.isNotEmpty) {
                      whoShouldActList.add({
                        'name': actorNameController.text.trim(),
                        'authority': actorAuthorityController.text.trim(),
                      });
                      actorNameController.clear();
                      actorAuthorityController.clear();
                    }
                  },
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Obx(
              () => Column(
                children: whoShouldActList
                    .map(
                      (actor) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    actor['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (actor['authority']!.isNotEmpty)
                                    Text(
                                      actor['authority']!,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.black54,
                              ),
                              onPressed: () => whoShouldActList.remove(actor),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Select Community',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCommunity.value,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: communityMap.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        selectedCommunity.value = newValue;
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    socialController.updateImpactStand(
                      id: widget.impactStand.id,
                      name: nameController.text.trim(),
                      community: selectedCommunity.value,
                      subHeading: subHeadingController.text.trim(),
                      description: descriptionController.text.trim(),
                      type: selectedType.value,
                      whoShouldAct: whoShouldActList.toList(),
                      imageFiles: imageFiles.toList(),
                      isPetition: isPetition.value,
                    );
                  } else {
                    Get.snackbar('Error', 'Please enter a name');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Stand',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(dynamic item) {
    if (item is String) {
      return UniversalImage(
        imageUrl: item,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (item is XFile) {
      return kIsWeb
          ? Image.network(
              item.path,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          : Image.file(
              File(item.path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
    }
    return const SizedBox();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildActionTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black87,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
