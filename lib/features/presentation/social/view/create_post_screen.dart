import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/social/controller/social_controller.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final SocialController controller = Get.find();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedState;
  String? selectedDistrict;

  // Simple dataset for now. Can be moved to a constants file or service later.
  final Map<String, List<String>> indiaLocations = {
    'Kerala': [
      'Thiruvananthapuram',
      'Kollam',
      'Pathanamthitta',
      'Alappuzha',
      'Kottayam',
      'Idukki',
      'Ernakulam',
      'Thrissur',
      'Palakkad',
      'Malappuram',
      'Kozhikode (Calicut)',
      'Wayanad',
      'Kannur',
      'Kasaragod',
    ],
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Tiruchirappalli',
      'Salem',
    ],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Mangaluru', 'Hubballi-Dharwad'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik'],
    // Add more as needed
  };

  @override
  Widget build(BuildContext context) {
    // Check if we are in the Blood Donations community
    // Note: The community ID might be 'BloodDonations' or 'o/BloodDonations' depending on how it's set.
    // Based on previous files, it seems to be 'BloodDonations' (pure ID) when switching.
    // Let's check logic: socialController.switchCommunity("BloodDonations");
    // So currentCommunity.value will be "BloodDonations".
    final isBloodDonation =
        controller.currentCommunity.value == 'BloodDonations';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (isBloodDonation &&
                  (selectedState == null || selectedDistrict == null)) {
                Get.snackbar(
                  'Error',
                  'Please select State and District for blood donation request.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              controller.addPost(
                titleController.text,
                descriptionController.text,
                locationState: selectedState,
                locationDistrict: selectedDistrict,
              );
            },
            child: const Text(
              'POST',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isBloodDonation) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select State'),
                    value: selectedState,
                    items: indiaLocations.keys.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedState = newValue;
                        selectedDistrict = null; // Reset district
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (isBloodDonation && selectedState != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select District'),
                    value: selectedDistrict,
                    items: indiaLocations[selectedState]!.map((
                      String district,
                    ) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedDistrict = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
            ],

            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'An interesting title',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              maxLines: null,
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Your text post (optional)',
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
