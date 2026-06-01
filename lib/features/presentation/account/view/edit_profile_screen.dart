import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';
import 'package:oulta/common/widgets/universal_image.dart';
import 'package:oulta/features/domain/account/entities/account_user.dart';
import 'package:oulta/common/constants/locations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final NameController _nameController = Get.find();
  late TextEditingController _nameEditingController;
  late TextEditingController _taglineEditingController;
  late TextEditingController _placeEditingController;

  String? selectedState;
  String? selectedDistrict;

  @override
  void initState() {
    super.initState();
    _nameEditingController = TextEditingController(
      text: _nameController.userName.value,
    );
    _taglineEditingController = TextEditingController(
      text: _nameController.tagline.value,
    );
    
    final String stateVal = _nameController.userState.value.trim();
    if (stateVal.isNotEmpty && indiaStatesAndDistricts.containsKey(stateVal)) {
      selectedState = stateVal;
    } else {
      selectedState = null;
    }
    
    final String districtVal = _nameController.userDistrict.value.trim();
    if (selectedState != null &&
        districtVal.isNotEmpty &&
        indiaStatesAndDistricts[selectedState]!.contains(districtVal)) {
      selectedDistrict = districtVal;
    } else {
      selectedDistrict = null;
    }
        
    _placeEditingController = TextEditingController(
      text: _nameController.userPlace.value,
    );
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _taglineEditingController.dispose();
    _placeEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final String name = _nameEditingController.text.trim();
              if (name.isEmpty) {
                Get.snackbar(
                  'Name Required',
                  'Full Name is a required field.',
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade900,
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }

              if (selectedState == null || selectedState!.isEmpty) {
                Get.snackbar(
                  'State Required',
                  'State is a required field for petition signer credibility.',
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade900,
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }

              if (selectedDistrict == null || selectedDistrict!.isEmpty) {
                Get.snackbar(
                  'District Required',
                  'District is a required field for petition signer credibility.',
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade900,
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }

              _nameController.saveProfile(
                name,
                _taglineEditingController.text,
                UserLocation(
                  name: name,
                  state: selectedState!,
                  district: selectedDistrict!,
                  place: _placeEditingController.text.trim(),
                ),
              );
              Get.back();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          _nameController.userPhotoUrl.value.isNotEmpty
                          ? getUniversalImageProvider(
                              _nameController.userPhotoUrl.value,
                            )
                          : null,
                      child: _nameController.userPhotoUrl.value.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        _nameController.pickAndUploadProfileImage();
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 18,
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _nameEditingController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _taglineEditingController,
              decoration: const InputDecoration(
                labelText: 'Tagline',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.style_outlined),
              ),
            ),
            const SizedBox(height: 20),
            
            // State Dropdown
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedState,
              decoration: const InputDecoration(
                labelText: 'State *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map_outlined),
              ),
              items: indiaStatesAndDistricts.keys.map((String state) {
                return DropdownMenuItem<String>(
                  value: state,
                  child: Text(state),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedState = newValue;
                  selectedDistrict = null; // Reset district when state changes
                });
              },
            ),
            const SizedBox(height: 20),

            // District Dropdown
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedDistrict,
              decoration: const InputDecoration(
                labelText: 'District *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              items: (selectedState != null && indiaStatesAndDistricts.containsKey(selectedState))
                  ? indiaStatesAndDistricts[selectedState]!.map((String district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district),
                      );
                    }).toList()
                  : null,
              onChanged: (newValue) {
                setState(() {
                  selectedDistrict = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            // Place/Town Optional Text Field
            TextFormField(
              controller: _placeEditingController,
              decoration: const InputDecoration(
                labelText: 'Place / Town (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.near_me_outlined),
                hintText: 'e.g. Nilambur',
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
