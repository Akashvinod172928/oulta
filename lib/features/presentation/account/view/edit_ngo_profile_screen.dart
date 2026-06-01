import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';
import 'package:oulta/common/widgets/universal_image.dart';

class EditNgoProfileScreen extends StatefulWidget {
  const EditNgoProfileScreen({Key? key}) : super(key: key);

  @override
  _EditNgoProfileScreenState createState() => _EditNgoProfileScreenState();
}

class _EditNgoProfileScreenState extends State<EditNgoProfileScreen> {
  final NameController _nameController = Get.find();
  late TextEditingController _ngoNameController;
  late TextEditingController _legalTypeController;
  late TextEditingController _registrationNumberController;
  late TextEditingController _registrationDateController;
  late TextEditingController _missionController;
  late TextEditingController _aboutController;
  late TextEditingController _keyProgramController;
  late TextEditingController _impactSnapshotController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _instagramController;
  late TextEditingController _focusAreasController;

  @override
  void initState() {
    super.initState();
    _ngoNameController = TextEditingController(
      text: _nameController.ngoName.value,
    );
    _legalTypeController = TextEditingController(
      text: _nameController.legalType.value,
    );
    _registrationNumberController = TextEditingController(
      text: _nameController.registrationNumber.value,
    );
    _registrationDateController = TextEditingController(
      text: _nameController.registrationDate.value,
    );
    _missionController = TextEditingController(
      text: _nameController.ngoMission.value,
    );
    _aboutController = TextEditingController(
      text: _nameController.shortAbout.value,
    );
    _keyProgramController = TextEditingController(
      text: _nameController.keyProgram.value,
    );
    _impactSnapshotController = TextEditingController(
      text: _nameController.impactSnapshot.value,
    );
    _emailController = TextEditingController(
      text: _nameController.contactInfo.value,
    );
    _phoneController = TextEditingController(text: _nameController.phone.value);
    _addressController = TextEditingController(
      text: _nameController.address.value,
    );
    _websiteController = TextEditingController(
      text: _nameController.website.value,
    );
    _instagramController = TextEditingController(
      text: _nameController.instagramLink.value,
    );
    _focusAreasController = TextEditingController(
      text: _nameController.focusAreas.join(', '),
    );
  }

  void _saveProfile() {
    final ngoData = {
      'ngoName': _ngoNameController.text,
      'legalType': _legalTypeController.text,
      'registrationNumber': _registrationNumberController.text,
      'registrationDate': _registrationDateController.text,
      'ngoMission': _missionController.text,
      'shortAbout': _aboutController.text,
      'keyProgram': _keyProgramController.text,
      'impactSnapshot': _impactSnapshotController.text,
      'contactInfo': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'website': _websiteController.text,
      'instagramLink': _instagramController.text,
      'focusAreas': _focusAreasController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
    };
    _nameController.saveNgoProfile(ngoData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit NGO Profile',
          style: TextStyle(fontFamily: 'Roboto', color: Colors.black),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NGO Logo Picker
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: _nameController.ngoLogo.value.isNotEmpty
                          ? getUniversalImageProvider(
                              _nameController.ngoLogo.value,
                            )
                          : null,
                      child: _nameController.ngoLogo.value.isEmpty
                          ? Icon(
                              Icons.business,
                              size: 40,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        _nameController.pickAndUploadNgoLogo();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            _buildTextField(_ngoNameController, 'NGO Name'),
            _buildTextField(
              _legalTypeController,
              'Legal Type (e.g., Trust, Society)',
            ),
            _buildTextField(
              _registrationNumberController,
              'Registration Number',
            ),
            _buildTextField(_registrationDateController, 'Registration Date'),

            const SizedBox(height: 24),
            _buildSectionHeader('About & Mission'),
            const SizedBox(height: 16),
            _buildTextField(
              _missionController,
              'Mission (1-2 lines)',
              maxLines: 3,
            ),
            _buildTextField(
              _aboutController,
              'Short About (3-4 lines)',
              maxLines: 5,
            ),
            _buildTextField(
              _focusAreasController,
              'Focus Areas (comma-separated)',
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Impact'),
            const SizedBox(height: 16),
            _buildTextField(_keyProgramController, 'One Key Program'),
            _buildTextField(
              _impactSnapshotController,
              'Impact Snapshot (e.g., 1000+ beneficiaries)',
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Contact Details'),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Contact Email'),
            _buildTextField(_phoneController, 'Phone Number'),
            _buildTextField(_addressController, 'Address (City, State)'),
            _buildTextField(_websiteController, 'Website URL'),
            _buildTextField(_instagramController, 'Instagram Link'),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: 'Roboto',
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
