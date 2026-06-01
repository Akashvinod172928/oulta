import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:oulta/features/presentation/social/widgets/impact_stand_card.dart';
import 'package:intl/intl.dart';
import 'package:oulta/features/presentation/social/controller/social_controller.dart';
import 'package:oulta/features/presentation/account/view/account_page.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';
import 'package:oulta/features/presentation/social/comments/widgets/comment_card.dart';
import 'package:oulta/features/presentation/profile/view/user_profile_page.dart';
import 'package:oulta/features/presentation/social/comments/controller/comment_controller.dart';
import 'package:oulta/common/widgets/universal_image.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';
import 'package:oulta/features/settings/edit_impact_stand_screen.dart';
import 'package:oulta/features/presentation/social/comments/view/report_comment_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oulta/features/data/social/services/firebase_service.dart';
import 'package:oulta/common/constants/locations.dart';
import 'package:oulta/features/domain/account/entities/account_user.dart';

const List<String> indianStates = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
  'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
  'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
  'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  'Andaman and Nicobar Islands', 'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu',
  'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
];

class ImpactStandDetailWrapper extends StatelessWidget {
  const ImpactStandDetailWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.arguments is ImpactStand) {
      return ImpactStandDetailPage(impactStand: Get.arguments as ImpactStand);
    }
    
    final id = Get.parameters['id'];
    if (id == null) {
      return const Scaffold(body: Center(child: Text('Stand not found')));
    }

    final firebaseService = Get.find<FirebaseService>();
    return FutureBuilder<Map<String, dynamic>?>(
      future: firebaseService.getImpactStandById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          final stand = ImpactStand(
            id: data['id'],
            standId: data['standId'] ?? '',
            name: data['name'],
            subHeading: data['subHeading'] ?? '',
            description: data['description'] ?? '',
            type: data['type'] ?? 'Other',
            whoShouldAct: data['whoShouldAct'] ?? [],
            community: data['community'],
            photoUrls: List<String>.from(data['photoUrls'] ?? []),
            standCount: data['standCount'],
            commentCount: data['commentCount'] ?? 0,
            hasTakenStand: data['hasTakenStand'],
            creatorId: data['creatorId'] ?? '',
            creatorEmail: data['creatorEmail'] ?? '',
            creatorName: data['creatorName'] ?? 'Anonymous',
            timestamp: data['timestamp'],
            status: data['status'] ?? 'active',
            isPetition: data['isPetition'] ?? false,
          );
          return ImpactStandDetailPage(impactStand: stand);
        }
        return const Scaffold(body: Center(child: Text('Stand not found')));
      },
    );
  }
}

class ImpactStandDetailPage extends StatefulWidget {
  final ImpactStand impactStand;

  const ImpactStandDetailPage({Key? key, required this.impactStand})
    : super(key: key);

  @override
  State<ImpactStandDetailPage> createState() => _ImpactStandDetailPageState();
}

class _ImpactStandDetailPageState extends State<ImpactStandDetailPage> {
  late bool isTaken;
  late int localCount;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  late final CommentController _commentControllerObj;
  final ScrollController _scrollController = ScrollController();
  bool _isActionInProgress = false;
  String _selectedLanguage = 'English';

  String get _displayTitle {
    if (_selectedLanguage == 'Malayalam') return 'ഇതൊരു ഡമ്മി തലക്കെട്ടാണ്';
    if (_selectedLanguage == 'Hindi') return 'यह एक डमी शीर्षक है';
    return widget.impactStand.name;
  }

  String get _displaySubHeading {
    if (widget.impactStand.subHeading.isEmpty) return '';
    if (_selectedLanguage == 'Malayalam') return 'ഇതൊരു ഡമ്മി ഉപശീർഷകമാണ്';
    if (_selectedLanguage == 'Hindi') return 'यह एक डमी उपशीर्षक है';
    return widget.impactStand.subHeading;
  }

  String get _displayDescription {
    if (widget.impactStand.description.isEmpty) return '';
    if (_selectedLanguage == 'Malayalam') return 'ഈ സ്റ്റാൻഡിനായുള്ള ഡമ്മി വിവരണമാണ് ഇത്. പ്രധാനമായും പ്രാദേശിക ഭാഷാ വിവർത്തനം പരിശോധിക്കുന്നതിനായി നൽകിയിട്ടുള്ള ടെക്സ്റ്റ്.';
    if (_selectedLanguage == 'Hindi') return 'यह इस स्टैंड के लिए एक डमी विवरण है। मुख्य रूप से क्षेत्रीय भाषा के अनुवाद का परीक्षण करने के लिए यहां रखा गया है।';
    return widget.impactStand.description;
  }

  @override
  void initState() {
    super.initState();
    isTaken = widget.impactStand.hasTakenStand;
    localCount = widget.impactStand.standCount;
    _commentControllerObj = Get.put(
      CommentController(
        targetId: widget.impactStand.id,
        source: CommentSource.impactStand,
      ),
      tag: widget.impactStand.id,
    );
    _scrollController.addListener(_onScroll);

    // Auto-open location signature sheet on load for unsigned petitions (only if logged in)
    // Delayed slightly to allow GetX page transition routing animations to complete safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.impactStand.isPetition && !isTaken && widget.impactStand.status != 'victory') {
        final socialController = Get.find<SocialController>();
        if (socialController.currentUserHandle.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !isTaken) {
              _handleToggleStand();
            }
          });
        }
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _commentControllerObj.fetchComments(isLoadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    Get.delete<CommentController>(tag: widget.impactStand.id);
    super.dispose();
  }

  Future<void> _handleAddComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final success = await _commentControllerObj.addComment(text);
    if (success) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
      // Update local comment count for UI
      setState(() {
        widget.impactStand.commentCount++;
      });
    }
  }

  void _showLanguageBottomSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Handle bar
                   Center(
                     child: Container(
                       width: 40,
                       height: 5,
                       decoration: BoxDecoration(
                         color: Colors.grey.shade300,
                         borderRadius: BorderRadius.circular(10),
                       ),
                     ),
                   ),
                   const SizedBox(height: 24),
                   const Text(
                     'Language Change',
                     style: TextStyle(
                       fontSize: 24,
                       fontWeight: FontWeight.w900,
                       letterSpacing: -0.5,
                     ),
                   ),
                   const SizedBox(height: 16),
                   _buildLanguageOption('English'),
                   const Divider(),
                   _buildLanguageOption('Malayalam'),
                   const Divider(),
                   _buildLanguageOption('Hindi'),
                   const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  Widget _buildLanguageOption(String language) {
    final bool isSelected = _selectedLanguage == language;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        language,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.black : Colors.grey.shade700,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.black) : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Get.back();
        Get.snackbar(
          'Language Updated',
          'Stand content translated to $language. (Preview mode)',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.black,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      },
    );
  }

  Future<Map<String, String>?> _showPetitionSigningBottomSheet({required bool isProfileMissing}) async {
    final nameController = Get.find<NameController>();
    
    // Prefill details from profile
    final initialName = nameController.userName.value;
    final initialState = nameController.userState.value;
    final initialDistrict = nameController.userDistrict.value;
    final initialPlace = nameController.userPlace.value;

    final TextEditingController nameEditController = TextEditingController(text: initialName);
    final TextEditingController placeEditController = TextEditingController(text: initialPlace);
    
    String? selectedState = initialState.isNotEmpty && indiaStatesAndDistricts.containsKey(initialState) ? initialState : null;
    String? selectedDistrict = selectedState != null && initialDistrict.isNotEmpty && indiaStatesAndDistricts[selectedState]!.contains(initialDistrict) ? initialDistrict : null;

    return await Get.bottomSheet<Map<String, String>>(
      GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.assignment_turned_in_rounded, color: Colors.amber.shade700, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          isProfileMissing ? 'Complete Signature Details' : 'Confirm Signature',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isProfileMissing
                          ? 'Please complete your details to sign this petition. They will be automatically saved to your profile for future signings.'
                          : 'Review your details before signing. These will be linked to this signature permanently to build campaigner credibility.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full Name
                    _buildFieldLabel('Full Name *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameEditController,
                      readOnly: !isProfileMissing,
                      decoration: _buildInputDecoration(isProfileMissing ? 'Enter your full name' : '').copyWith(
                        prefixIcon: const Icon(Icons.person_outline),
                        fillColor: isProfileMissing ? Colors.grey.shade50 : Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // State Selection
                    _buildFieldLabel('State *'),
                    const SizedBox(height: 8),
                    isProfileMissing
                        ? DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedState,
                            decoration: _buildInputDecoration('Select your state').copyWith(
                              prefixIcon: const Icon(Icons.map_outlined),
                            ),
                            items: indiaStatesAndDistricts.keys.map((state) {
                              return DropdownMenuItem(value: state, child: Text(state));
                            }).toList(),
                            onChanged: (val) {
                              setModalState(() {
                                selectedState = val;
                                selectedDistrict = null; // Reset district
                              });
                            },
                          )
                        : TextFormField(
                            initialValue: selectedState,
                            readOnly: true,
                            decoration: _buildInputDecoration('').copyWith(
                              prefixIcon: const Icon(Icons.map_outlined),
                              fillColor: Colors.grey.shade100,
                            ),
                          ),
                    const SizedBox(height: 16),

                    // District Selection
                    _buildFieldLabel('District *'),
                    const SizedBox(height: 8),
                    isProfileMissing
                        ? DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedDistrict,
                            decoration: _buildInputDecoration('Select your district').copyWith(
                              prefixIcon: const Icon(Icons.location_city_outlined),
                            ),
                            items: (selectedState != null && indiaStatesAndDistricts.containsKey(selectedState))
                                ? indiaStatesAndDistricts[selectedState]!.map((district) {
                                    return DropdownMenuItem(value: district, child: Text(district));
                                  }).toList()
                                : null,
                            onChanged: (val) {
                              setModalState(() {
                                selectedDistrict = val;
                              });
                            },
                          )
                        : TextFormField(
                            initialValue: selectedDistrict,
                            readOnly: true,
                            decoration: _buildInputDecoration('').copyWith(
                              prefixIcon: const Icon(Icons.location_city_outlined),
                              fillColor: Colors.grey.shade100,
                            ),
                          ),
                    const SizedBox(height: 16),

                    // Place / Town
                    _buildFieldLabel(isProfileMissing ? 'Place / Town (Optional)' : 'Place / Town'),
                    const SizedBox(height: 8),
                    isProfileMissing
                        ? TextFormField(
                            controller: placeEditController,
                            decoration: _buildInputDecoration('e.g. Nilambur').copyWith(
                              prefixIcon: const Icon(Icons.near_me_outlined),
                            ),
                          )
                        : (initialPlace.isNotEmpty
                            ? TextFormField(
                                initialValue: initialPlace,
                                readOnly: true,
                                decoration: _buildInputDecoration('').copyWith(
                                  prefixIcon: const Icon(Icons.near_me_outlined),
                                  fillColor: Colors.grey.shade100,
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.near_me_outlined, color: Colors.grey.shade400, size: 20),
                                    const SizedBox(width: 12),
                                    Text('Not specified', style: TextStyle(color: Colors.grey.shade500)),
                                  ],
                                ),
                              )),
                    const SizedBox(height: 24),
                    
                    if (!isProfileMissing)
                      Text(
                        'Note: To permanently change these details, visit your Profile Settings.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameEditController.text.trim();
                          if (name.isEmpty) {
                            Get.snackbar(
                              'Name Required',
                              'Please enter your full name to sign.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red.shade50,
                              colorText: Colors.red.shade900,
                            );
                            return;
                          }
                          if (selectedState == null || selectedState!.isEmpty) {
                            Get.snackbar(
                              'State Required',
                              'Please select a state to sign.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red.shade50,
                              colorText: Colors.red.shade900,
                            );
                            return;
                          }
                          if (selectedDistrict == null || selectedDistrict!.isEmpty) {
                            Get.snackbar(
                              'District Required',
                              'Please select a district to sign.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red.shade50,
                              colorText: Colors.red.shade900,
                            );
                            return;
                          }

                          Get.back(
                            result: {
                              'name': name,
                              'state': selectedState!,
                              'district': selectedDistrict!,
                              'place': placeEditController.text.trim(),
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isProfileMissing ? 'Save Details & Sign Petition' : 'Confirm Signature',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
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
      isScrollControlled: true,
      ignoreSafeArea: false,
      enableDrag: true,
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: Colors.black,
        letterSpacing: 0.2,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
    );
  }

  Future<void> _handleToggleStand() async {
    if (_isActionInProgress) return;
    
    final socialController = Get.find<SocialController>();
    if (socialController.currentUserHandle.isEmpty) {
      Get.to(() => const AccountScreen());
      return;
    }

    if (isTaken) return;

    final nameController = Get.find<NameController>();
    
    String? name;
    String? state;
    String? district;
    String? place;

    if (widget.impactStand.isPetition) {
      // Determine if profile details are missing
      final hasName = nameController.userName.value.trim().isNotEmpty;
      final String stateVal = nameController.userState.value.trim();
      final String districtVal = nameController.userDistrict.value.trim();
      
      final hasState = stateVal.isNotEmpty && indiaStatesAndDistricts.containsKey(stateVal);
      final hasDistrict = hasState && districtVal.isNotEmpty && indiaStatesAndDistricts[stateVal]!.contains(districtVal);

      final isProfileMissing = !hasName || !hasState || !hasDistrict;

      // Open the dynamic Petition Signing Bottom Sheet
      _isActionInProgress = true;
      final locationData = await _showPetitionSigningBottomSheet(isProfileMissing: isProfileMissing);
      if (locationData == null) {
        _isActionInProgress = false;
        return;
      }

      if (isTaken) {
        _isActionInProgress = false;
        return;
      }

      name = locationData['name']!;
      state = locationData['state']!;
      district = locationData['district']!;
      place = locationData['place']!;

      // Automatically sync and save newly filled details to user profile
      if (isProfileMissing) {
        try {
          await nameController.saveProfile(
            name,
            nameController.tagline.value,
            UserLocation(
              name: name,
              state: state,
              district: district,
              place: place,
            ),
          );
        } catch (saveError) {
          debugPrint("Optional profile auto-save failed: $saveError");
        }
      }
    } else {
      _isActionInProgress = true;
    }

    if (!mounted) return;
    setState(() {
      isTaken = true;
      localCount++;
      widget.impactStand.hasTakenStand = true;
      widget.impactStand.standCount = localCount;
    });

    try {
      await socialController.toggleStand(
        widget.impactStand.id,
        true,
        name: name,
        state: state,
        district: district,
        place: place,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isTaken = false;
          localCount--;
          widget.impactStand.hasTakenStand = false;
          widget.impactStand.standCount = localCount;
        });
      }
      Get.snackbar('Error', 'Failed to update stand. Please try again.');
    } finally {
      _isActionInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = widget.impactStand.timestamp != null
        ? DateFormat('MMMM d, y').format(widget.impactStand.timestamp!)
        : 'Unknown Date';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.impactStand.status == 'victory' ? 'Victory Details' : 'Impact Stand',
        hasActionButton: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _commentControllerObj.fetchComments(),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Image Section
                  SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: widget.impactStand.photoUrls.isEmpty
                              ? SvgPicture.asset(
                                  'assets/social_icons/Black and Purple Gradient Coming Soon A4 Landscape.svg',
                                  fit: BoxFit.cover,
                                  placeholderBuilder: (context) => Container(
                                    color: Colors.black87,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                )
                              : Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    PageView.builder(
                                      itemCount:
                                          widget.impactStand.photoUrls.length,
                                      itemBuilder: (context, index) {
                                        return UniversalImage(
                                          imageUrl: widget
                                              .impactStand
                                              .photoUrls[index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        );
                                      },
                                    ),
                                    if (widget.impactStand.photoUrls.length >
                                        1)
                                      Positioned(
                                        bottom: 20,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            widget
                                                .impactStand
                                                .photoUrls
                                                .length,
                                            (index) => Container(
                                              margin: const EdgeInsets.all(4),
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                        // Taken Container - Left side
                        Positioned(
                          bottom: -20,
                          left: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.flag_rounded,
                                  color: Colors.black,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.impactStand.isPetition
                                      ? '$localCount Signed'
                                      : '$localCount Taken',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Share Container - Right side
                        Positioned(
                          bottom: -20,
                          right: 24,
                          child: GestureDetector(
                            onTap: () async {
                              final String urlToShare = kIsWeb 
                                ? Uri.base.toString() 
                                : 'https://oulta.web.app/#/impact-stand?id=${widget.impactStand.id}';
                              
                              final String title = widget.impactStand.name;
                              final String standIdStr = widget.impactStand.standId.isNotEmpty ? ' (Stand ID: ${widget.impactStand.standId})' : '';
                              final String subtitle = widget.impactStand.subHeading;
                              final String shareText = subtitle.isNotEmpty 
                                  ? '$title$standIdStr\n$subtitle\n\n$urlToShare'
                                  : '$title$standIdStr\n\n$urlToShare';
                              
                              try {
                                await Share.share(shareText);
                              } catch (e) {
                                // Fallback to copy if Share API fails
                                await Clipboard.setData(ClipboardData(text: urlToShare));
                                Get.snackbar(
                                  'Link Copied',
                                  'Impact Stand link copied to clipboard!',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.black87,
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 12,
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12), // Box shape
                                border: Border.all(color: Colors.black, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.share_rounded,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Share',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 30)),

                  // Content Section
                  SliverPadding(
                    padding: const EdgeInsets.all(24.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Community Tag & Date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'o/${widget.impactStand.community}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.impactStand.isPetition
                                              ? Colors.amber.shade50
                                              : Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          widget.impactStand.isPetition ? 'PETITION' : 'IMPACT STAND',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                            color: widget.impactStand.isPetition
                                                ? Colors.amber.shade900
                                                : Colors.blue.shade900,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          widget.impactStand.type,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                            color: Colors.purple.shade700,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (Get.find<NameController>().userId.isNotEmpty &&
                                    Get.find<NameController>().userId.trim() ==
                                        widget.impactStand.creatorId.trim())
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_note_rounded,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      Get.to(
                                        () => EditImpactStandScreen(
                                          impactStand: widget.impactStand,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Creator Display
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person_pin_rounded, size: 14, color: Colors.grey.shade400),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Posted by u/${widget.impactStand.creatorName}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _showLanguageBottomSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.translate_rounded, size: 14, color: Colors.grey.shade800),
                                        const SizedBox(width: 4),
                                        Text(
                                          _selectedLanguage,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.grey.shade800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey.shade600),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.impactStand.standId.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: widget.impactStand.standId));
                                  Get.snackbar(
                                    'Copied',
                                    'Stand ID ${widget.impactStand.standId} copied to clipboard!',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.black87,
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: 12,
                                    duration: const Duration(seconds: 1),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.grey.shade200, width: 0.8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Stand ID: ${widget.impactStand.standId}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.copy_all_rounded,
                                        size: 11,
                                        color: Colors.grey.shade400,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Heading
                        Hero(
                          tag: 'stand_title_${widget.impactStand.id}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              _displayTitle,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),

                        // Sub-heading
                        if (_displaySubHeading.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            _displaySubHeading,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                              height: 1.3,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        Divider(color: Colors.grey.shade200, thickness: 1),
                        const SizedBox(height: 24),

                        // Description
                        if (_displayDescription.isNotEmpty)
                          Text(
                            _displayDescription,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.grey.shade700,
                            ),
                          )
                        else
                          Text(
                            "No description provided for this stand.",
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Who Should Act Section
                        if (widget.impactStand.whoShouldAct.isNotEmpty) ...[
                          const Text(
                            'Who Should Act',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...widget.impactStand.whoShouldAct.map((actor) {
                            final String name = actor['name'] ?? 'Unknown';
                            final String authority = actor['authority'] ?? '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.black,
                                    radius: 20,
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                        ),
                                        if (authority.isNotEmpty)
                                          Text(
                                            authority,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.gavel_rounded,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],

                        const SizedBox(height: 40),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Comments Heading
                        Obx(
                          () => Text(
                            'Comments (${_commentControllerObj.comments.length})',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ]),
                    ),
                  ),

                  // Comments List
                  Obx(() {
                    if (_commentControllerObj.isFirstLoad.value &&
                        _commentControllerObj.isLoading.value) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (_commentControllerObj.comments.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'No comments yet. Be the first to comment!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.only(top: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final comment = _commentControllerObj.comments[index];
                          return CommentCard(
                            comment: comment,
                            onVote: (voteState, isUpvote) =>
                                _commentControllerObj.voteOnComment(
                                  comment.id,
                                  voteState,
                                  isUpvote,
                                ),
                            onUsernameTap: () {
                              Get.to(
                                () => UserProfilePage(
                                  username: comment.authorHandle,
                                ),
                              );
                            },
                            onReport: () {
                              Get.to(() => ReportCommentScreen(
                                comment: comment,
                                standId: widget.impactStand.id,
                                standName: widget.impactStand.name,
                              ));
                            },
                          );
                        }, childCount: _commentControllerObj.comments.length),
                      ),
                    );
                  }),

                  // Loading More Indicator
                  Obx(() {
                    if (_commentControllerObj.isLoading.value &&
                        !_commentControllerObj.isFirstLoad.value) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),

          // Sticky Comment Input at bottom
          _buildCommentInput(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: widget.impactStand.status == 'victory'
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade300, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber.shade900, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'VICTORY ACHIEVED! 🏆',
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                )
              : _ImpactStandActionButton(
                  isTaken: isTaken,
                  isPetition: widget.impactStand.isPetition,
                  onToggle: _handleToggleStand,
                ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black12,
                  child: Icon(Icons.person, color: Colors.black54, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => _commentControllerObj.isAddingComment.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      onPressed: _handleAddComment,
                      icon: const Icon(Icons.send_rounded),
                      color: Colors.black,
                    ),
            ),
          ],
        ),
      ),
     ),
    ],
   );
  }
}

class _ImpactStandActionButton extends StatelessWidget {
  final bool isTaken;
  final bool isPetition;
  final VoidCallback onToggle;

  const _ImpactStandActionButton({
    Key? key,
    required this.isTaken,
    required this.isPetition,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isTaken ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: isTaken ? 2 : 0),
          boxShadow: isTaken
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isTaken)
                  Icon(
                    isPetition ? Icons.assignment_turned_in_rounded : Icons.front_hand_rounded,
                    color: Colors.black,
                    size: 20,
                  )
                else
                  Icon(
                    isPetition ? Icons.assignment_turned_in_rounded : Icons.front_hand_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 10),
                Text(
                  isTaken
                      ? (isPetition ? 'Stand Taken & Petition Signed' : 'Stand Taken')
                      : (isPetition ? 'Take Stand & Sign Petition' : 'Take Stand'),
                  style: TextStyle(
                    color: isTaken ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              isTaken
                  ? 'Thank you for your support'
                  : (isPetition ? 'Take the stand and sign the petition' : 'Take the stand to support'),
              style: TextStyle(
                color: isTaken ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
