import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/profile/controller/profile_controller.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';
import 'package:oulta/features/data/social/services/firebase_service.dart';
import 'package:oulta/features/home/community_controller.dart';
import 'package:oulta/features/presentation/social/view/create_post_screen.dart';
import 'package:oulta/features/presentation/social/widgets/post_card.dart';
import 'package:oulta/features/presentation/social/widgets/impact_stand_card.dart';
import 'package:oulta/features/presentation/social/widgets/campaign_card.dart';
import 'package:oulta/features/presentation/social/comments/widgets/comment_card.dart';
import 'package:oulta/features/presentation/social/widgets/victory_card.dart';

class SocialController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final NameController _nameController = Get.find<NameController>();
  final RxBool isUploading = false.obs;

  final posts = <Post>[].obs;

  // This list now stores ALL impact stands for the CURRENT community
  final impactStands = <ImpactStand>[].obs;
  
  // Stores ALL campaigns for the CURRENT community
  final campaigns = <Campaign>[].obs;

  // Stores ALL victory stands for the CURRENT community
  final victoryStands = <VictoryStand>[].obs;

  final selectedTab = 'Impact Stands'.obs; // Default tab
  final isLoading = false.obs;
  final hasMore = true.obs;

  // ── Home feed — cross-community ──────────────────────────────
  final homeImpactStands = <ImpactStand>[].obs;
  final homeCampaigns = <Campaign>[].obs;
  final homeVictoryStands = <VictoryStand>[].obs;
  final homeSelectedTab = 'Impact Stands'.obs;
  final homeIsLoading = false.obs;
  final homeCommunityFilter = 'all'.obs;

  RxString get currentCommunity => FirebaseService.currentCommunity;

  void switchCommunity(String id) {
    _firebaseService.switchCommunity(id);

    // Reset state for the new community
    isLoading.value = false;
    posts.clear();
    _lastDocument = null;
    hasMore.value = true;

    // Refresh both posts, impact stands, and campaigns for the new community
    refreshPosts();
    fetchImpactStands();
    fetchCampaigns();
    fetchVictoryStands();
  }

  DocumentSnapshot? _lastDocument;
  final int _postsLimit = 5;

  String get currentUserHandle => _nameController.userName.value;
  String get currentUserPhotoUrl => _nameController.userPhotoUrl.value;

  @override
  void onInit() {
    super.onInit();
    final communityController = Get.find<CommunityController>();

    // Listen for auth changes to refresh data
    ever(_nameController.currentUserRx, (_) {
      print("User changed, refreshing social data...");
      fetchImpactStands();
      fetchCampaigns();
      refreshPosts();
      fetchVictoryStands();
      
      // Refresh home feed for 'india' community only
      fetchHomeFeed(['india']);
    });

    fetchInitialPosts();
    fetchImpactStands(); // Fetch stands on init
    fetchCampaigns(); // Fetch campaigns on init
    fetchVictoryStands();

    // ── Home feed sync ─────────────────────────────────────────
    
    // Listen to community join/leave events to refresh feed for 'india' community only
    ever(communityController.joinedIds, (_) {
      print("DEBUG: Joined communities changed. Refreshing home feed for india");
      fetchHomeFeed(['india']);
    });

    // Initial home feed fetch for 'india' community only
    fetchHomeFeed(['india']);
  }

  /// Fetch Impact Stands and Campaigns from all [communityIds] for the home feed.
  Future<void> fetchHomeFeed(List<String> communityIds) async {
    if (communityIds.isEmpty) return;
    try {
      homeIsLoading.value = true;
      final takenIds = _nameController.takenStandIds;

      final standsData = await _firebaseService.getImpactStands(
        'india',
        takenIds,
      );
      homeImpactStands.value = standsData
          .map(
            (data) => ImpactStand(
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
            ),
          )
          .toList();

      final campaignsData = await _firebaseService.getCampaigns(
        'india',
        takenIds,
      );
      homeCampaigns.value = campaignsData
          .map(
            (data) => Campaign(
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
            ),
          )
          .toList();

      // Also fetch all victory stands for the home feed
      final rawVictories = await _firebaseService.getVictoryStands();
      homeVictoryStands.value = rawVictories.map((data) {
        return VictoryStand(
          id: data['id'] ?? '',
          campaignStandId: data['campaignStandId'] ?? '',
          campaignId: data['campaignId'] ?? '',
          companyId: data['companyId'] ?? '',
          companyName: data['companyName'] ?? '',
          victoryTitle: data['victoryTitle'] ?? '',
          victoryDescription: data['victoryDescription'] ?? '',
          beforeImages: List<String>.from(data['beforeImages'] ?? []),
          afterImages: List<String>.from(data['afterImages'] ?? []),
          createdAt: data['createdAt'] ?? DateTime.now(),
          victoryNote: data['victoryNote'] ?? '',
          victoryWhoActed: data['victoryWhoActed'] ?? [],
          campaignName: data['campaignName'] ?? '',
          campaignSubHeading: data['campaignSubHeading'] ?? '',
          campaignDescription: data['campaignDescription'] ?? '',
          campaignType: data['campaignType'] ?? 'Other',
          campaignWhoShouldAct: data['campaignWhoShouldAct'] ?? [],
          campaignCommunity: data['campaignCommunity'] ?? 'india',
          campaignPhotoUrls: List<String>.from(data['campaignPhotoUrls'] ?? []),
          campaignStandCount: data['campaignStandCount'] ?? 0,
          campaignCreatorId: data['campaignCreatorId'] ?? '',
          campaignCreatorName: data['campaignCreatorName'] ?? 'Anonymous',
          campaignCreatorEmail: data['campaignCreatorEmail'] ?? '',
          isImpactStand: data['isImpactStand'] ?? false,
        );
      }).toList();

    } catch (e) {
      print('Error in fetchHomeFeed: $e');
    } finally {
      homeIsLoading.value = false;
    }
  }

  Future<void> fetchImpactStands() async {
    try {
      isLoading.value = true;
      final takenIds = _nameController.takenStandIds;
      print(
        'Fetching Impact Stands for user: $currentUserHandle, taken: ${takenIds.length}',
      );
      final dataList = await _firebaseService.getImpactStands(
        currentCommunity.value,
        takenIds,
      );

      print('=== fetchImpactStands: Got ${dataList.length} stands ===');
      for (final data in dataList) {
        print('  Stand ID: ${data['id']}, name: ${data['name']}');
        print('  photoUrls raw: ${data['photoUrls']}');
        print('  photoUrls type: ${data['photoUrls']?.runtimeType}');
      }

      impactStands.value = dataList
          .map(
            (data) => ImpactStand(
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
            ),
          )
          .toList();

      print('=== impactStands mapped: ${impactStands.length} ===');
      for (final s in impactStands) {
        print('  STAND: ${s.name}');
        print('    ID: ${s.id}');
        print('    photoUrls count: ${s.photoUrls.length}');
        for (int i = 0; i < s.photoUrls.length; i++) {
          print('    URL[$i]: ${s.photoUrls[i]}');
        }
      }
    } catch (e) {
      print("Error fetching impact stands: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCampaigns() async {
    try {
      isLoading.value = true;
      final takenIds = _nameController.takenStandIds; 
      
      final dataList = await _firebaseService.getCampaigns(
        currentCommunity.value,
        takenIds,
      );

      campaigns.value = dataList
          .map(
            (data) => Campaign(
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
            ),
          )
          .toList();

    } catch (e) {
      print("Error fetching campaigns: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVictoryStands() async {
    try {
      isLoading.value = true;
      print('=== fetchVictoryStands: currentCommunity = "${currentCommunity.value}" ===');
      final rawList = await _firebaseService.getVictoryStands();
      print('=== fetchVictoryStands: Got ${rawList.length} raw records from Firebase ===');

      for (final data in rawList) {
        print('  Victory raw: id=${data['id']}, campaignCommunity="${data['campaignCommunity']}", title="${data['victoryTitle']}"');
      }

      // Show all victory stands (not filtered by community) — same behavior as Campaigns tab
      victoryStands.value = rawList.map((data) {
        return VictoryStand(
          id: data['id'] ?? '',
          campaignStandId: data['campaignStandId'] ?? '',
          campaignId: data['campaignId'] ?? '',
          companyId: data['companyId'] ?? '',
          companyName: data['companyName'] ?? '',
          victoryTitle: data['victoryTitle'] ?? '',
          victoryDescription: data['victoryDescription'] ?? '',
          beforeImages: List<String>.from(data['beforeImages'] ?? []),
          afterImages: List<String>.from(data['afterImages'] ?? []),
          createdAt: data['createdAt'] ?? DateTime.now(),
          victoryNote: data['victoryNote'] ?? '',
          victoryWhoActed: data['victoryWhoActed'] ?? [],
          campaignName: data['campaignName'] ?? '',
          campaignSubHeading: data['campaignSubHeading'] ?? '',
          campaignDescription: data['campaignDescription'] ?? '',
          campaignType: data['campaignType'] ?? 'Other',
          campaignWhoShouldAct: data['campaignWhoShouldAct'] ?? [],
          campaignCommunity: data['campaignCommunity'] ?? 'india',
          campaignPhotoUrls: List<String>.from(data['campaignPhotoUrls'] ?? []),
          campaignStandCount: data['campaignStandCount'] ?? 0,
          campaignCreatorId: data['campaignCreatorId'] ?? '',
          campaignCreatorName: data['campaignCreatorName'] ?? 'Anonymous',
          campaignCreatorEmail: data['campaignCreatorEmail'] ?? '',
          isImpactStand: data['isImpactStand'] ?? false,
        );
      }).toList();

      print('=== fetchVictoryStands: Loaded ${victoryStands.length} victory stands ===');

    } catch (e) {
      print("Error fetching victory stands: $e");
      Get.snackbar(
        "Error loading Victories",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleStand(
    String standId,
    bool isTakingStand, {
    String? name,
    String? state,
    String? district,
    String? place,
  }) async {
    try {
      // Use UID, not header/name, for database operations on User doc
      final uid = _nameController.userId;
      if (uid.isEmpty) return;

      await _firebaseService.toggleImpactStand(
        standId,
        uid,
        isTakingStand,
        email: _nameController.userEmail.value,
        name: name,
        state: state,
        district: district,
        place: place,
      );

      // Update local in-memory lists immediately
      final idx1 = impactStands.indexWhere((s) => s.id == standId);
      if (idx1 != -1) {
        impactStands[idx1].hasTakenStand = isTakingStand;
        impactStands[idx1].standCount += isTakingStand ? 1 : -1;
      }
      final idx2 = homeImpactStands.indexWhere((s) => s.id == standId);
      if (idx2 != -1) {
        homeImpactStands[idx2].hasTakenStand = isTakingStand;
        homeImpactStands[idx2].standCount += isTakingStand ? 1 : -1;
      }
      impactStands.refresh();
      homeImpactStands.refresh();

      // Refresh local user data to get updated 'takenStandIds'
      await _nameController.loadUserData();

      // Also refresh profile if active
      final myHandle = _nameController.userName.value;
      if (myHandle.isNotEmpty &&
          Get.isRegistered<ProfileController>(tag: myHandle)) {
        Get.find<ProfileController>(
          tag: myHandle,
        ).fetchUserData(isRefresh: true);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update stand: $e");
    }
  }

  Future<void> toggleCampaign(
    String campaignId,
    bool isTakingStand, {
    String? name,
    String? state,
    String? district,
    String? place,
  }) async {
    try {
      final uid = _nameController.userId;
      if (uid.isEmpty) return;

      await _firebaseService.toggleCampaign(
        campaignId,
        uid,
        isTakingStand,
        email: _nameController.userEmail.value,
        name: name,
        state: state,
        district: district,
        place: place,
      );

      // Update local in-memory lists immediately
      final idx1 = campaigns.indexWhere((c) => c.id == campaignId);
      if (idx1 != -1) {
        campaigns[idx1].hasTakenStand = isTakingStand;
        campaigns[idx1].standCount += isTakingStand ? 1 : -1;
      }
      final idx2 = homeCampaigns.indexWhere((c) => c.id == campaignId);
      if (idx2 != -1) {
        homeCampaigns[idx2].hasTakenStand = isTakingStand;
        homeCampaigns[idx2].standCount += isTakingStand ? 1 : -1;
      }
      campaigns.refresh();
      homeCampaigns.refresh();

      await _nameController.loadUserData();

      final myHandle = _nameController.userName.value;
      if (myHandle.isNotEmpty &&
          Get.isRegistered<ProfileController>(tag: myHandle)) {
        Get.find<ProfileController>(
          tag: myHandle,
        ).fetchUserData(isRefresh: true);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update campaign: $e");
    }
  }

  Future<void> fetchInitialPosts() async {
    if (isLoading.isTrue) return;

    try {
      isLoading.value = true;
      hasMore.value = true;
      _lastDocument = null;

      final postSnapshots = await _firebaseService.getPostsPaginated(
        limit: _postsLimit,
      );

      if (postSnapshots.isNotEmpty) {
        _lastDocument = postSnapshots.last;
        posts.value = postSnapshots
            .map(
              (doc) =>
                  _firebaseService.mapSnapshotToPost(doc, currentUserHandle),
            )
            .toList();
      } else {
        posts.value = [];
      }

      if (postSnapshots.length < _postsLimit) {
        hasMore.value = false;
      }
    } catch (e) {
      print("Error fetching posts: $e");
      Get.snackbar("Error", "Failed to load posts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMorePosts() async {
    if (isLoading.isTrue || !hasMore.isTrue) return;

    try {
      isLoading.value = true;
      final postSnapshots = await _firebaseService.getPostsPaginated(
        limit: _postsLimit,
        startAfter: _lastDocument,
      );

      if (postSnapshots.isNotEmpty) {
        _lastDocument = postSnapshots.last;
        posts.addAll(
          postSnapshots.map(
            (doc) => _firebaseService.mapSnapshotToPost(doc, currentUserHandle),
          ),
        );
      }

      if (postSnapshots.length < _postsLimit) {
        hasMore.value = false;
      }
    } catch (e) {
      print("Error fetching more posts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPosts() async {
    return fetchInitialPosts();
  }

  // Updated to navigate to the new creation screen
  void navigateToCreatePost() {
    if (!_nameController.isLoggedIn.value) {
      Get.snackbar('Login Required', 'You must be signed in to create a post.');
      return;
    }
    Get.to(() => const CreatePostScreen());
  }

  // This method now takes a title and an optional description
  Future<void> addPost(
    String title,
    String? description, {
    String? locationState,
    String? locationDistrict,
  }) async {
    if (title.trim().isEmpty) {
      Get.snackbar('Error', 'A title is required to create a post.');
      return;
    }

    try {
      // If posting as NGO, use NGO name as author; if company, use company name; otherwise user name
      final String postAuthorHandle = _nameController.profileType.value == "ngo"
          ? _nameController.ngoName.value
          : (_nameController.profileType.value == "company"
              ? _nameController.companyName.value
              : currentUserHandle);

      final String? companyHandle = _nameController.profileType.value == "company"
          ? _nameController.userName.value
          : null;

      final String? ngoHandle = _nameController.profileType.value == "ngo"
          ? _nameController.userName.value
          : null;

      await _firebaseService.addPost(
        title,
        description,
        postAuthorHandle,
        currentUserPhotoUrl,
        ngoHandle: ngoHandle,
        companyHandle: companyHandle,
        locationState: locationState,
        locationDistrict: locationDistrict,
      );
      await refreshPosts();
      Get.back(); // Go back from the create post screen
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create post: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addImpactStand(
    String name,
    String community,
    String subHeading,
    String description,
    String type,
    List<Map<String, String>> whoShouldAct,
    List<dynamic> imageFiles,
    bool isPetition,
  ) async {
    try {
      print('DEBUG: SocialController.addImpactStand started');
      isUploading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      // 1. Upload images to Firebase Storage
      print(
        'DEBUG: Calling uploadImpactStandImages with ${imageFiles.length} files',
      );
      final List<String> photoUrls = List<String>.from(
        await _firebaseService.uploadImpactStandImages(imageFiles),
      );
      print('DEBUG: Image upload successful. URLs: $photoUrls');

      // 2. Add impact stand with the resulting URLs
      print('DEBUG: Calling FirebaseService.addImpactStand');
      await _firebaseService.addImpactStand(
        name,
        community,
        subHeading,
        description,
        type,
        whoShouldAct,
        photoUrls,
        _nameController.userId,
        _nameController.userEmail.value,
        _nameController.userName.value,
        isPetition,
      );
      print('DEBUG: Impact Stand added to Firestore successfully');

      Get.back(); // Close Loading Dialog
      Get.back(); // Close Creation Screen
      Get.snackbar('Success', 'Impact Stand created!');

      // If we added to the current community, refresh the list
      if (community == currentCommunity.value) {
        selectedTab.value = 'Impact Stands';
        fetchImpactStands();
      }

      // Also refresh the home feed for 'india' community only
      fetchHomeFeed(['india']);

      // Also refresh the current user's profile if it's currently open/active
      final myHandle = _nameController.userName.value;
      if (myHandle.isNotEmpty &&
          Get.isRegistered<ProfileController>(tag: myHandle)) {
        Get.find<ProfileController>(
          tag: myHandle,
        ).fetchUserData(isRefresh: true);
      }
    } catch (e) {
      print('DEBUG: ERROR in SocialController.addImpactStand: $e');
      Get.back(); // Close Loading Dialog
      Get.snackbar("Error", "Failed to create stand: $e");
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> addCampaign(
    String name,
    String community,
    String subHeading,
    String description,
    String type,
    List<dynamic> whoShouldAct,
    List<dynamic> imageFiles,
  ) async {
    try {
      print('DEBUG: SocialController.addCampaign started');
      isUploading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      print('DEBUG: Calling uploadImpactStandImages for campaign');
      final List<String> photoUrls = List<String>.from(
          await _firebaseService.uploadImpactStandImages(imageFiles));

      await _firebaseService.addCampaign(
        name,
        community,
        subHeading,
        description,
        type,
        whoShouldAct,
        photoUrls,
        _nameController.userId,
        _nameController.userEmail.value,
        _nameController.userName.value,
      );
      print('DEBUG: Campaign added to Firestore successfully');

      Get.back(); // Close Loading Dialog
      Get.back(); // Close Creation Screen
      Get.snackbar('Success', 'Campaign created!');

      // If we added to the current community, refresh the list
      if (community == currentCommunity.value) {
        selectedTab.value = 'Campaigns';
        fetchCampaigns();
      }

      // Also refresh the home feed for 'india' community only
      fetchHomeFeed(['india']);

      // Also refresh the current user's profile if active
      final myHandle = _nameController.userName.value;
      if (myHandle.isNotEmpty &&
          Get.isRegistered<ProfileController>(tag: myHandle)) {
        Get.find<ProfileController>(
          tag: myHandle,
        ).fetchUserData(isRefresh: true);
      }
    } catch (e) {
      print('DEBUG: ERROR in SocialController.addCampaign: $e');
      Get.back(); // Close Loading Dialog
      Get.snackbar("Error", "Failed to create campaign: $e");
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> updateImpactStand({
    required String id,
    required String name,
    required String community,
    required String subHeading,
    required String description,
    required String type,
    required List<Map<String, String>> whoShouldAct,
    required List<dynamic> imageFiles, // Can be XFile or String (URL)
    required bool isPetition,
  }) async {
    try {
      isUploading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      // Separate new files from existing URLs
      final List<dynamic> newFiles = imageFiles
          .where((f) => f is! String)
          .toList();
      final List<String> existingUrls = imageFiles.whereType<String>().toList();

      // 1. Upload NEW images to Firebase Storage
      final List<String> newUrls = List<String>.from(
        await _firebaseService.uploadImpactStandImages(newFiles),
      );

      final List<String> finalUrls = [...existingUrls, ...newUrls];

      // 2. Update impact stand with the resulting URLs
      await _firebaseService.updateImpactStand(
        id: id,
        name: name,
        community: community,
        subHeading: subHeading,
        description: description,
        type: type,
        whoShouldAct: whoShouldAct,
        photoUrls: finalUrls,
        isPetition: isPetition,
      );

      Get.back(); // Close Loading Dialog
      Get.back(); // Close Edit Screen
      Get.snackbar('Success', 'Impact Stand updated!');

      // Refresh data
      fetchImpactStands();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print("Error updating impact stand: $e");
      Get.snackbar('Error', 'Failed to update impact stand: $e');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> vote(
    String postId,
    VoteState currentVote,
    bool isUpvoteButton,
  ) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = posts[index];
    int newScore = post.score;
    VoteState newVoteState = VoteState.none;

    if (isUpvoteButton) {
      if (currentVote == VoteState.up) {
        newScore--;
        newVoteState = VoteState.none;
      } else {
        newScore += (currentVote == VoteState.down) ? 2 : 1;
        newVoteState = VoteState.up;
      }
    } else {
      if (currentVote == VoteState.down) {
        newScore++;
        newVoteState = VoteState.none;
      } else {
        newScore -= (currentVote == VoteState.up) ? 2 : 1;
        newVoteState = VoteState.down;
      }
    }

    posts[index] = Post(
      id: post.id,
      authorHandle: post.authorHandle,
      authorPhotoUrl: post.authorPhotoUrl,
      title: post.title,
      description: post.description,
      timestamp: post.timestamp,
      score: newScore,
      commentCount: post.commentCount,
      myVote: newVoteState,
      ngoHandle: post.ngoHandle,
      isVerified: post.isVerified,
      communityHandle: post.communityHandle,
    );

    try {
      await _firebaseService.updatePostVote(
        postId,
        currentUserHandle,
        currentVote,
        isUpvoteButton,
      );
    } catch (e) {
      posts[index] = post; // Revert on error
    }
  }

  // --- Impact Stand Comment Methods ---

  Future<void> addImpactStandComment(String standId, String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _firebaseService.addImpactStandComment(
        standId: standId,
        text: text,
        authorHandle: currentUserHandle,
        authorPhotoUrl: currentUserPhotoUrl,
      );
      // We don't necessarily need to refresh everything, but we should refresh the stand's comment count
      final index = impactStands.indexWhere((s) => s.id == standId);
      if (index != -1) {
        impactStands[index].commentCount++;
        impactStands.refresh();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add comment: $e");
    }
  }

  Future<List<Comment>> getImpactStandComments(String standId) async {
    try {
      final snapshots = await _firebaseService.getImpactStandComments(
        standId: standId,
      );
      return snapshots
          .map(
            (doc) =>
                _firebaseService.mapSnapshotToComment(doc, currentUserHandle),
          )
          .toList();
    } catch (e) {
      print("Error fetching impact stand comments: $e");
      return [];
    }
  }

  Future<void> voteImpactStandComment(
    String standId,
    String commentId,
    VoteState currentVote,
    bool isUpvoteButton,
  ) async {
    try {
      await _firebaseService.updateImpactStandCommentVote(
        standId,
        commentId,
        currentUserHandle,
        currentVote,
        isUpvoteButton,
      );
    } catch (e) {
      Get.snackbar("Error", "Vote failed: $e");
    }
  }
}
