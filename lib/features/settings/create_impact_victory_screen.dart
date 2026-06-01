import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/data/social/services/firebase_service.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';
import 'package:oulta/features/presentation/social/controller/social_controller.dart';

class CreateImpactVictoryScreen extends StatefulWidget {
  const CreateImpactVictoryScreen({super.key});

  @override
  State<CreateImpactVictoryScreen> createState() => _CreateImpactVictoryScreenState();
}

class _CreateImpactVictoryScreenState extends State<CreateImpactVictoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  // Step 1: Impact Stand Search
  final TextEditingController _standIdController = TextEditingController();
  Map<String, dynamic>? _selectedImpactStand;
  bool _searchingImpactStand = false;

  // Step 2: Acting Authority Details (Dynamic list input)
  final RxList<Map<String, String>> _victoryWhoActedList = <Map<String, String>>[].obs;
  final TextEditingController _actorNameController = TextEditingController();
  final TextEditingController _actorAuthorityController = TextEditingController();

  // Step 3: Victory Details
  final TextEditingController _victoryTitleController = TextEditingController();
  final TextEditingController _victorySubTitleController = TextEditingController();
  final TextEditingController _victoryDescriptionController = TextEditingController();
  final TextEditingController _victoryNoteController = TextEditingController();
  final TextEditingController _beforeImagesController = TextEditingController();
  final TextEditingController _afterImagesController = TextEditingController();

  bool _isCreating = false;

  Future<void> _searchImpactStand() async {
    final standId = _standIdController.text.trim();
    if (standId.isEmpty) {
      Get.snackbar("Error", "Please enter an Impact Stand ID");
      return;
    }

    setState(() {
      _searchingImpactStand = true;
      _selectedImpactStand = null;
    });

    try {
      final stand = await _firebaseService.getImpactStandByStandId(standId);
      setState(() {
        _selectedImpactStand = stand;
        if (stand != null) {
          // Pre-populate fields automatically from matching Impact Stand
          _victoryTitleController.text = stand['name'] ?? '';
          _victorySubTitleController.text = stand['subHeading'] ?? '';
          _victoryDescriptionController.text = stand['description'] ?? '';
          
          // Pre-populate Who Should Act list as the baseline for resolving list
          _victoryWhoActedList.clear();
          if (stand['whoShouldAct'] is List) {
            for (final item in stand['whoShouldAct']) {
              if (item is Map) {
                _victoryWhoActedList.add({
                  'name': (item['name'] ?? '').toString(),
                  'authority': (item['authority'] ?? '').toString(),
                });
              }
            }
          }
        }
      });

      if (stand == null) {
        Get.snackbar("Not Found", "No impact stand found with ID '$standId'");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to search impact stand: $e");
    } finally {
      setState(() {
        _searchingImpactStand = false;
      });
    }
  }

  Future<void> _createVictory() async {
    if (_selectedImpactStand == null) {
      Get.snackbar("Validation Error", "Please select an Impact Stand first");
      return;
    }

    if (_victoryWhoActedList.isEmpty) {
      Get.snackbar("Validation Error", "Please add at least one agency or authority who resolved this victory");
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final beforeUrls = _beforeImagesController.text
          .split(',')
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      final afterUrls = _afterImagesController.text
          .split(',')
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      // Ensure fallbacks if images aren't pasted to keep visual grid complete
      if (beforeUrls.isEmpty) {
        beforeUrls.add("https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=600");
      }
      if (afterUrls.isEmpty) {
        afterUrls.add("https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?q=80&w=600");
      }

      await _firebaseService.convertImpactStandToVictory(
        impactStandId: _selectedImpactStand!['id'],
        impactStandCode: _selectedImpactStand!['standId'],
        companyId: 'authority',
        companyName: _victoryWhoActedList.map((a) => a['name'] ?? '').join(', '),
        victoryTitle: _victoryTitleController.text.trim(),
        victorySubTitle: _victorySubTitleController.text.trim(),
        victoryDescription: _victoryDescriptionController.text.trim(),
        victoryNote: _victoryNoteController.text.trim(),
        victoryWhoActed: _victoryWhoActedList.toList(),
        beforeImages: beforeUrls,
        afterImages: afterUrls,
        impactStandData: _selectedImpactStand!,
      );

      // Trigger instant UI refresh in SocialController
      if (Get.isRegistered<SocialController>()) {
        final socialController = Get.find<SocialController>();
        await socialController.fetchVictoryStands();
        await socialController.fetchImpactStands();
      }

      Get.snackbar(
        "Success 🎉",
        "Victory Stand successfully created from Impact Stand!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Go back to Settings
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to create Victory: $e");
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
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

  @override
  void dispose() {
    _standIdController.dispose();
    _actorNameController.dispose();
    _actorAuthorityController.dispose();
    _victoryTitleController.dispose();
    _victorySubTitleController.dispose();
    _victoryDescriptionController.dispose();
    _victoryNoteController.dispose();
    _beforeImagesController.dispose();
    _afterImagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const CustomAppBar(title: 'CREATE IMPACT VICTORY', hasActionButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Convert an active Impact Stand into a celebrated Victory Stand resolved by the government or authority.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // SECTION 1: SEARCH IMPACT STAND
              _buildSectionHeader("1. SEARCH IMPACT STAND"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _standIdController,
                      decoration: const InputDecoration(
                        labelText: "Impact Stand ID",
                        hintText: "IM-DDMMYY-HHMMSS",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _searchingImpactStand ? null : _searchImpactStand,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _searchingImpactStand
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Search", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Preview Selected Impact Stand
              if (_selectedImpactStand != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedImpactStand!['standId'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "IMPACT MATCHED",
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedImpactStand!['name'] ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedImpactStand!['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          Chip(
                            label: Text(_selectedImpactStand!['community'] ?? 'india'),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          Chip(
                            label: Text("Creator: ${_selectedImpactStand!['creatorName']}"),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else if (!_searchingImpactStand) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Text(
                      "Enter an Impact Stand ID above and click Search.",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // SECTION 2: WHO RESOLVED THIS VICTORY?
              _buildSectionHeader("2. WHO RESOLVED THIS VICTORY?"),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _actorNameController,
                          decoration: _inputDecoration('Name/Agency (e.g. Local Municipality)'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _actorAuthorityController,
                          decoration: _inputDecoration('Authority/Role (e.g. District Collector)'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: () {
                      if (_actorNameController.text.isNotEmpty) {
                        _victoryWhoActedList.add({
                          'name': _actorNameController.text.trim(),
                          'authority': _actorAuthorityController.text.trim(),
                        });
                        _actorNameController.clear();
                        _actorAuthorityController.clear();
                      } else {
                        Get.snackbar("Validation Error", "Please enter an Agency Name");
                      }
                    },
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(backgroundColor: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Added Actors List
              Obx(
                () => Column(
                  children: _victoryWhoActedList
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
                                onPressed: () => _victoryWhoActedList.remove(actor),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 3: VICTORY DETAILS
              _buildSectionHeader("3. VICTORY DETAILS"),
              const SizedBox(height: 12),

              // Title
              TextFormField(
                controller: _victoryTitleController,
                decoration: const InputDecoration(
                  labelText: "Victory Title",
                  hintText: "e.g. Kerala Solar Initiative Successful!",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a Victory Title";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subtitle
              TextFormField(
                controller: _victorySubTitleController,
                decoration: const InputDecoration(
                  labelText: "Victory Subtitle / Tagline",
                  hintText: "e.g. Demand resolved by district collector",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a Victory Subtitle";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _victoryDescriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Victory Story / Description",
                  hintText: "Describe the positive outcome and collaborative impact...",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a Victory Description";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Victory Note
              TextFormField(
                controller: _victoryNoteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Victory Note (Special Accomplishment Remarks)",
                  hintText: "Enter an inspiring victory note outlining what was achieved...",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a Victory Note";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Before Images (URLs)
              TextFormField(
                controller: _beforeImagesController,
                decoration: const InputDecoration(
                  labelText: "Before Image URLs",
                  hintText: "Paste image URL (comma separated if multiple)",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // After Images (URLs)
              TextFormField(
                controller: _afterImagesController,
                decoration: const InputDecoration(
                  labelText: "After Image URLs",
                  hintText: "Paste image URL (comma separated if multiple)",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createVictory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isCreating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Create Victory Stand",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.black87,
      ),
    );
  }
}
