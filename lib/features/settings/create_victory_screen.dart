import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/data/social/services/firebase_service.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';
import 'package:oulta/features/presentation/social/controller/social_controller.dart';

class CreateVictoryScreen extends StatefulWidget {
  const CreateVictoryScreen({super.key});

  @override
  State<CreateVictoryScreen> createState() => _CreateVictoryScreenState();
}

class _CreateVictoryScreenState extends State<CreateVictoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  // Step 1: Campaign Search
  final TextEditingController _standIdController = TextEditingController();
  Map<String, dynamic>? _selectedCampaign;
  bool _searchingCampaign = false;

  // Step 2: Company Search
  final TextEditingController _companySearchController = TextEditingController();
  List<Map<String, dynamic>> _matchingCompanies = [];
  Map<String, dynamic>? _selectedCompany;
  bool _searchingCompanies = false;

  // Step 3: Victory Details
  final TextEditingController _victoryTitleController = TextEditingController();
  final TextEditingController _victoryDescriptionController = TextEditingController();
  final TextEditingController _beforeImagesController = TextEditingController();
  final TextEditingController _afterImagesController = TextEditingController();

  bool _isCreating = false;

  Future<void> _searchCampaign() async {
    final standId = _standIdController.text.trim();
    if (standId.isEmpty) {
      Get.snackbar("Error", "Please enter a Campaign Stand ID");
      return;
    }

    setState(() {
      _searchingCampaign = true;
      _selectedCampaign = null;
    });

    try {
      final campaign = await _firebaseService.getCampaignByStandId(standId);
      setState(() {
        _selectedCampaign = campaign;
      });

      if (campaign == null) {
        Get.snackbar("Not Found", "No campaign stand found with ID '$standId'");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to search campaign: $e");
    } finally {
      setState(() {
        _searchingCampaign = false;
      });
    }
  }

  Future<void> _searchCompanies(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _matchingCompanies = [];
      });
      return;
    }

    setState(() {
      _searchingCompanies = true;
    });

    try {
      final results = await _firebaseService.searchCompaniesByName(query);
      setState(() {
        _matchingCompanies = results;
      });
    } catch (e) {
      print("Error searching companies: $e");
    } finally {
      setState(() {
        _searchingCompanies = false;
      });
    }
  }

  Future<void> _createVictory() async {
    if (_selectedCampaign == null) {
      Get.snackbar("Validation Error", "Please select a Campaign Stand first");
      return;
    }

    if (_selectedCompany == null) {
      Get.snackbar("Validation Error", "Please select a corporate sponsor (Company)");
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

      await _firebaseService.convertCampaignToVictory(
        campaignId: _selectedCampaign!['id'],
        campaignStandId: _selectedCampaign!['standId'],
        companyId: _selectedCompany!['uid'],
        companyName: _selectedCompany!['companyName'],
        victoryTitle: _victoryTitleController.text.trim(),
        victoryDescription: _victoryDescriptionController.text.trim(),
        beforeImages: beforeUrls,
        afterImages: afterUrls,
        campaignData: _selectedCampaign!,
      );

      // Trigger instant UI refresh in SocialController
      if (Get.isRegistered<SocialController>()) {
        final socialController = Get.find<SocialController>();
        await socialController.fetchVictoryStands();
        await socialController.fetchCampaigns();
      }

      Get.snackbar(
        "Success 🎉",
        "Victory Stand successfully created!",
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

  @override
  void dispose() {
    _standIdController.dispose();
    _companySearchController.dispose();
    _victoryTitleController.dispose();
    _victoryDescriptionController.dispose();
    _beforeImagesController.dispose();
    _afterImagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const CustomAppBar(title: 'CREATE VICTORY', hasActionButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Convert an active NGO Campaign Stand into a celebrated Victory Stand.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // SECTION 1: SEARCH CAMPAIGN STAND
              _buildSectionHeader("1. SEARCH CAMPAIGN STAND"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _standIdController,
                      decoration: const InputDecoration(
                        labelText: "Campaign Stand ID",
                        hintText: "CP-DDMMYY-HHMMSS",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _searchingCampaign ? null : _searchCampaign,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _searchingCampaign
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

              // Preview Selected Campaign
              if (_selectedCampaign != null) ...[
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
                            _selectedCampaign!['standId'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "CAMPAIGN MATCHED",
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedCampaign!['name'] ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedCampaign!['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          Chip(
                            label: Text(_selectedCampaign!['community'] ?? 'india'),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          Chip(
                            label: Text("NGO: ${_selectedCampaign!['creatorName']}"),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else if (!_searchingCampaign) ...[
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
                      "Enter a Campaign Stand ID above and click Search.",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // SECTION 2: SELECT COMPANY
              _buildSectionHeader("2. SELECT CORPORATE SPONSOR"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _companySearchController,
                decoration: const InputDecoration(
                  labelText: "Search Company Name",
                  hintText: "Type company name...",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _searchCompanies,
              ),
              const SizedBox(height: 12),

              // Matching Companies Listing
              if (_selectedCompany != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.domain, color: Colors.teal.shade800),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCompany!['companyName'],
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                            ),
                            Text(
                              _selectedCompany!['companyIndustry'].isNotEmpty
                                  ? _selectedCompany!['companyIndustry']
                                  : "Selected Partner",
                              style: TextStyle(fontSize: 12, color: Colors.teal.shade800),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _selectedCompany = null;
                            _companySearchController.clear();
                            _matchingCompanies = [];
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ] else if (_matchingCompanies.isNotEmpty) ...[
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _matchingCompanies.length,
                    itemBuilder: (context, index) {
                      final company = _matchingCompanies[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE0F2F1),
                          child: Icon(Icons.domain, color: Colors.teal),
                        ),
                        title: Text(company['companyName']),
                        subtitle: Text(company['companyIndustry']),
                        trailing: const Icon(Icons.add_circle_outline, color: Colors.teal),
                        onTap: () {
                          setState(() {
                            _selectedCompany = company;
                            _matchingCompanies = [];
                            _companySearchController.clear();
                          });
                        },
                      );
                    },
                  ),
                ),
              ] else if (_companySearchController.text.isNotEmpty && !_searchingCompanies) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "No companies found matching '${_companySearchController.text}'",
                    style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                  ),
                ),
              ],
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
