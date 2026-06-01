import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';
import 'package:oulta/common/widgets/universal_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:oulta/features/presentation/social/widgets/campaign_card.dart';
import 'package:oulta/features/presentation/social/controller/social_controller.dart';
import 'package:oulta/features/presentation/account/view/account_page.dart';
// If you create EditCampaignScreen in future, import it here:
// import 'package:oulta/features/settings/edit_campaign_screen.dart';
import 'package:oulta/features/presentation/profile/view/user_profile_page.dart';
import 'package:oulta/features/presentation/social/comments/controller/comment_controller.dart';
import 'package:oulta/features/presentation/social/comments/widgets/comment_card.dart';
import 'package:oulta/features/presentation/social/comments/view/report_comment_screen.dart';

const List<String> indianStates = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
  'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
  'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
  'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  'Andaman and Nicobar Islands', 'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu',
  'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
];

class CampaignDetailPage extends StatefulWidget {
  final Campaign campaign;

  const CampaignDetailPage({Key? key, required this.campaign}) : super(key: key);

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  late bool isTaken;
  late int localCount;
  final TextEditingController _commentController = TextEditingController();
  late final CommentController _commentControllerObj;
  final ScrollController _scrollController = ScrollController();
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    isTaken = widget.campaign.hasTakenStand;
    localCount = widget.campaign.standCount;
    // We treat campaign comments similar to impact stand comments for now
    _commentControllerObj = Get.put(
      CommentController(
        targetId: widget.campaign.id,
        source: CommentSource.impactStand, // Reusing impactStand comment source or define campaign source if needed
      ),
      tag: 'camp_${widget.campaign.id}',
    );
    _scrollController.addListener(_onScroll);
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
    Get.delete<CommentController>(tag: 'camp_${widget.campaign.id}');
    super.dispose();
  }

  Future<void> _handleAddComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final success = await _commentControllerObj.addComment(text);
    if (success) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
      setState(() {
        widget.campaign.commentCount++;
      });
    }
  }

  Future<Map<String, String>?> _showLocationBottomSheet() async {
    final TextEditingController districtController = TextEditingController();
    String? selectedState;

    return await Get.bottomSheet<Map<String, String>>(
      GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Wrap(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          'Join the Movement',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tell us your location to verify your impact in this community.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        _buildFieldLabel('State *'),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          decoration: _buildInputDecoration('Select your state'),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          items: indianStates.map((state) {
                            return DropdownMenuItem(value: state, child: Text(state));
                          }).toList(),
                          onChanged: (val) => selectedState = val,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        _buildFieldLabel('District (Optional)'),
                        const SizedBox(height: 10),
                        TextField(
                          controller: districtController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _buildInputDecoration('e.g. Kozhikode, Ernakulam'),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedState == null) {
                                Get.snackbar(
                                  'State Required', 
                                  'Please pick a state to continue',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.red.shade50,
                                  colorText: Colors.red.shade900,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 12,
                                );
                                return;
                              }
                              Get.back(
                                result: {
                                  'state': selectedState!,
                                  'district': districtController.text.trim(),
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
                            child: const Text(
                              'Confirm & Take Stand',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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

  Future<void> _handleToggleCampaign() async {
    if (_isActionInProgress) return;
    
    final socialController = Get.find<SocialController>();
    if (socialController.currentUserHandle.isEmpty) {
      Get.to(() => const AccountScreen());
      return;
    }

    if (isTaken) return;

    _isActionInProgress = true;
    
    final locationData = await _showLocationBottomSheet();
      if (locationData == null) {
        _isActionInProgress = false;
        return;
      }

      if (isTaken) {
        _isActionInProgress = false;
        return;
      }

      final String state = locationData['state']!;
      final String district = locationData['district']!;

      setState(() {
        isTaken = true;
        localCount++;
        widget.campaign.hasTakenStand = true;
        widget.campaign.standCount = localCount;
      });

    try {
      await socialController.toggleCampaign(
        widget.campaign.id,
        true,
        state: state,
        district: district,
      );
    } catch (e) {
      setState(() {
        isTaken = false;
        localCount--;
        widget.campaign.hasTakenStand = false;
        widget.campaign.standCount = localCount;
      });
      Get.snackbar('Error', 'Failed to support campaign. Please try again.');
    } finally {
      _isActionInProgress = false;
    }
  }

  IconData _getStakeholderIcon(String category) {
    switch (category) {
      case 'Corporates, Trusts & CSR Funders':
        return Icons.business_center_rounded;
      case 'Government & Local Authorities':
        return Icons.account_balance_rounded;
      case 'NGOs & Social Organizations':
        return Icons.groups_3_rounded;
      case 'Retail Individuals':
        return Icons.person_rounded;
      case 'HNIs (High Net Worth Individuals)':
        return Icons.diamond_rounded;
      case 'Volunteers & Local Communities':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.handshake_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = widget.campaign.timestamp != null
        ? DateFormat('MMMM d, y').format(widget.campaign.timestamp!)
        : 'Unknown Date';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.campaign.status == 'victory' ? 'Victory Details' : 'Campaign Details',
        trailingIcon: Icons.share_outlined,
        onTrailingIconPressed: () {
          // TODO: Implement share
        },
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
                          child: widget.campaign.photoUrls.isEmpty
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
                                      itemCount: widget.campaign.photoUrls.length,
                                      itemBuilder: (context, index) {
                                        return UniversalImage(
                                          imageUrl: widget.campaign.photoUrls[index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        );
                                      },
                                    ),
                                    if (widget.campaign.photoUrls.length > 1)
                                      Positioned(
                                        bottom: 20,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            widget.campaign.photoUrls.length,
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
                        Positioned(
                          bottom: -20,
                          right: 24,
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
                                  '$localCount Taken',
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
                                          'o/${widget.campaign.community}',
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
                                          color: Colors.purple.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          widget.campaign.type,
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
                              ],
                            ),
                            const SizedBox(height: 10),
                             // Creator Display
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.business_rounded, size: 14, color: Colors.grey.shade400),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Campaign by u/${widget.campaign.creatorName}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.campaign.status == 'victory' && widget.campaign.companyName.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.domain_rounded, size: 14, color: Colors.teal.shade500),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Victory led by: ${widget.campaign.companyName} (Corporate Sponsor)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.teal.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            if (widget.campaign.standId.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: widget.campaign.standId));
                                  Get.snackbar(
                                    'Copied',
                                    'Campaign ID ${widget.campaign.standId} copied to clipboard!',
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
                                        'Campaign ID: ${widget.campaign.standId}',
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
                          tag: 'campaign_title_${widget.campaign.id}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              widget.campaign.status == 'victory' && widget.campaign.victoryTitle.isNotEmpty
                                  ? widget.campaign.victoryTitle
                                  : widget.campaign.name,
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
                        if (widget.campaign.subHeading.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.campaign.subHeading,
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
                        if (widget.campaign.status == 'victory' && widget.campaign.victoryDescription.isNotEmpty)
                          Text(
                            widget.campaign.victoryDescription,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.grey.shade700,
                            ),
                          )
                        else if (widget.campaign.description.isNotEmpty)
                          Text(
                            widget.campaign.description,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.grey.shade700,
                            ),
                          )
                        else
                          Text(
                            "No description provided for this campaign.",
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Who Should Act Section
                        if (widget.campaign.whoShouldAct.isNotEmpty) ...[
                          Text(
                            widget.campaign.whoShouldAct.first is Map
                                ? 'Partners / Associated Actors'
                                : 'Target Stakeholders',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (widget.campaign.whoShouldAct.first is Map)
                            ...widget.campaign.whoShouldAct.map((actor) {
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
                                        Icons.handshake_rounded,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList()
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 10,
                              children: widget.campaign.whoShouldAct.map((cat) {
                                final String categoryStr = cat.toString();
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getStakeholderIcon(categoryStr),
                                        size: 16,
                                        color: Colors.blue.shade800,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          categoryStr,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
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
                                standId: widget.campaign.id,
                                standName: widget.campaign.name,
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
          child: widget.campaign.status == 'victory'
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
              : _CampaignActionButton(
                  isTaken: isTaken,
                  onToggle: _handleToggleCampaign,
                ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
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
    );
  }
}

class _CampaignActionButton extends StatelessWidget {
  final bool isTaken;
  final VoidCallback onToggle;

  const _CampaignActionButton({
    Key? key,
    required this.isTaken,
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
        padding: const EdgeInsets.symmetric(vertical: 16),
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
                  const Icon(
                    Icons.front_hand_rounded,
                    color: Colors.black,
                    size: 20,
                  )
                else
                  const Icon(
                    Icons.front_hand_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 10),
                Text(
                  isTaken ? 'Stand Taken' : 'Take Stand',
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
              isTaken ? 'Thank you for your support' : 'Take the stand to support',
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
