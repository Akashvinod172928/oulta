import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oulta/features/presentation/social/controller/social_controller.dart';

class CreateCampaignScreen extends StatelessWidget {
  const CreateCampaignScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SocialController socialController = Get.find<SocialController>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController subHeadingController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    // Reactive V1 Target Stakeholders selection list
    final RxList<String> selectedStakeholders = <String>[].obs;

    // Photos list (Local Files)
    final RxList<XFile> imageFiles = <XFile>[].obs;
    final ImagePicker _picker = ImagePicker();

    // Available communities with display names
    final Map<String, String> communityMap = {
      'india': 'India',
      'kerala': 'Kerala',
    };
    final RxString selectedCommunity = communityMap.keys.first.obs;

    final RxString selectedType = 'Fundraiser'.obs;
    final List<String> campaignTypes = [
      'Fundraiser',
      'Awareness',
      'Relief Effort',
      'Advocacy',
      'Community Action',
      'Other'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create a Campaign',
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
              'Campaign Name (Heading)',
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
                    items: campaignTypes.map((String value) {
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
                        .pickMultiImage(
                          imageQuality: 70, // Compress slightly
                          maxWidth: 1024,
                        );
                    if (pickedFiles.isNotEmpty) {
                      imageFiles.addAll(pickedFiles);
                    }
                  },
                  icon: const Icon(Icons.add_a_photo, color: Colors.blue),
                  label: const Text(
                    'Add Photos',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
                        border: Border.all(
                          color: Colors.grey.shade200,
                          style: BorderStyle.solid,
                        ),
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
                            'No photos added yet',
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
                                  child: kIsWeb
                                      ? Image.network(
                                          imageFiles[index].path,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Image.file(
                                          File(imageFiles[index].path),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
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
              'Who Should Act? *',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select at least one target stakeholder category for this campaign.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 16),

            Obx(() {
              final List<Map<String, dynamic>> stakeholderCategories = [
                {
                  'title': 'Corporates, Trusts & CSR Funders',
                  'desc': 'Supporting social impact initiatives through CSR partnerships, sponsorships, and responsible funding.',
                  'icon': Icons.business_center_rounded,
                },
                {
                  'title': 'Government & Local Authorities',
                  'desc': 'Supporting civic problem-solving, public welfare initiatives, and policy-level intervention.',
                  'icon': Icons.account_balance_rounded,
                },
                {
                  'title': 'NGOs & Social Organizations',
                  'desc': 'Collaborating for community outreach, volunteering, execution, and impact amplification.',
                  'icon': Icons.groups_3_rounded,
                },
                {
                  'title': 'Retail Individuals',
                  'desc': 'Empowering citizens to contribute directly to social and community-driven initiatives.',
                  'icon': Icons.person_rounded,
                },
                {
                  'title': 'HNIs (High Net Worth Individuals)',
                  'desc': 'Partnering with purpose-driven initiatives to create measurable social impact outcomes.',
                  'icon': Icons.diamond_rounded,
                },
                {
                  'title': 'Volunteers & Local Communities',
                  'desc': 'Encouraging local participation, collective action, and ground-level community support.',
                  'icon': Icons.volunteer_activism_rounded,
                },
              ];

              return Column(
                children: stakeholderCategories.map((cat) {
                  final String title = cat['title'];
                  final String desc = cat['desc'];
                  final IconData icon = cat['icon'];
                  final bool isSelected = selectedStakeholders.contains(title);

                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        selectedStakeholders.remove(title);
                      } else {
                        selectedStakeholders.add(title);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade200,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: isSelected ? Colors.blue.shade800 : Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.blue.shade900 : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected ? Colors.blue.shade800.withOpacity(0.8) : Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),

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
                  if (nameController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter a name');
                    return;
                  }
                  if (selectedStakeholders.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please select at least one target stakeholder category under "Who Should Act?"',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red.shade50,
                      colorText: Colors.red.shade900,
                    );
                    return;
                  }

                  socialController.addCampaign(
                    nameController.text.trim(),
                    selectedCommunity.value,
                    subHeadingController.text.trim(),
                    descriptionController.text.trim(),
                    selectedType.value,
                    selectedStakeholders.toList(),
                    imageFiles.toList(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: Colors.blue.withOpacity(0.5),
                ),
                child: const Text(
                  'Create Campaign',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
