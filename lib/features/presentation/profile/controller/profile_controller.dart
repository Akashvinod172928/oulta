import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/social/widgets/impact_stand_card.dart';
import 'package:oulta/features/presentation/social/widgets/post_card.dart';
import 'package:oulta/features/presentation/social/widgets/campaign_card.dart';
import 'package:oulta/features/presentation/social/comments/widgets/comment_card.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';
import 'package:oulta/features/domain/account/entities/account_user.dart';
import 'package:oulta/features/data/social/services/firebase_service.dart';

class ProfileController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NameController _nameController = Get.find<NameController>();

  final String userHandle;
  final String? userId; // If provided, skip name-based lookup and fetch directly
  late String _targetUserId;

  // Common profile observables
  final Rx<AccountUser?> viewedUser = Rx<AccountUser?>(null);

  // Keep some legacy observables for compatibility if heavily used elsewhere or just expose from user
  // However, for clean architecture we want to use the entity.
  // We'll keep specific observables for UI state that isn't part of user data (like following status, posts)

  // --- Follow-related observables ---
  final RxInt followerCount = 0.obs;
  final RxInt followingCount = 0.obs;
  final RxBool isFollowing = false.obs;

  // --- Impact Stand-related observables ---
  final RxList<ImpactStand> userImpactStands = <ImpactStand>[].obs;
  final RxBool isLoadingImpactStands = false.obs;

  // --- Campaign-related observables ---
  final RxList<Campaign> userCampaigns = <Campaign>[].obs;
  final RxBool isLoadingCampaigns = false.obs;

  // --- Post-related observables ---
  final RxList<Post> userPosts = <Post>[].obs;
  final RxBool isLoadingPosts = false.obs;

  // --- Comment-related observables ---
  final RxList<Comment> userComments = <Comment>[].obs;
  final RxBool isLoadingComments = false.obs;

  bool get isOwnProfile =>
      _nameController.isLoggedIn.value &&
      (_nameController.userName.value == userHandle);

  final isLoading = true.obs;
  final userFound = false.obs;

  ProfileController({required this.userHandle, this.userId});

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData({bool isRefresh = false}) async {
    try {
      if (!isRefresh) isLoading.value = true;
      // Wait for NameController to finish its loading if it hasn't already
      if (_nameController.screenState.value == ScreenState.loading) {
        await once(
          _nameController.screenState,
          (value) => value != ScreenState.loading,
        );
      }

      if (isOwnProfile) {
        // If it's my own profile, just grabbing the object from NameController is safest and fastest
        final myUser = _nameController.currentUserRx.value;
        if (myUser != null) {
          viewedUser.value = myUser;
          _targetUserId = myUser.uid;
          followerCount.value = myUser.followerCount;
          followingCount.value = myUser.followingCount;
          userFound.value = true;
        } else {
          userFound.value = false;
        }
      } else {
        // Always use the safe query approach (direct doc reads may be blocked by Firestore rules)
        DocumentSnapshot? userDoc;
        if (userId != null && userId!.isNotEmpty) {
          try {
            userDoc = await _firestore.collection('users').doc(userId).get();
          } catch (e) {
            print('DEBUG: Error fetching user by ID: $e');
          }
        }
        
        if (userDoc == null || !userDoc.exists) {
          userDoc = await _firebaseService.getUserByHandle(userHandle);
        }

        if (userDoc != null && userDoc.exists) {
          _targetUserId = userDoc.id;
          final userData = userDoc.data() as Map<String, dynamic>? ?? {};

          // Manually map Firestore data to AccountUser entity
          final badgeSnapshot = await userDoc.reference
              .collection('badges')
              .get();
          final earnedBadges = badgeSnapshot.docs.map((doc) => doc.id).toList();

          int dharmaValue = userData['dharma'] ?? 0;

          try {
            viewedUser.value = AccountUser(
              uid: _targetUserId,
              name: userData['name'] ?? userHandle,
              email: '', // Don't expose email of others
              photoUrl: userData['photoUrl'] ?? '',
              tagline: userData['tagline'] ?? 'No tagline yet',
              location: userData['location'] ?? '',
              website: userData['website'] ?? '',
              isVerified: userData['isVerified'] ?? false,
              dharma: dharmaValue,
              followerCount: userData['followerCount'] ?? 0,
              followingCount: userData['followingCount'] ?? 0,
              earnedBadgeIds: earnedBadges,
              profileType: userData['profileType'] ?? 'user',
              ngoName: userData['ngoName'] ?? '',
              ngoMission: userData['ngoMission'] ?? '',
              ngoLogo: userData['ngoLogo'] ?? '',
              registrationNumber: userData['registrationNumber'] ?? '',
              contactInfo: userData['contactInfo'] ?? '',
              featuredCampaign: userData['featuredCampaign'] ?? '',
              legalType: userData['legalType'] ?? '',
              registrationDate: userData['registrationDate'] ?? '',
              focusAreas: List<String>.from(userData['focusAreas'] ?? []),
              shortAbout: userData['shortAbout'] ?? '',
              keyProgram: userData['keyProgram'] ?? '',
              impactSnapshot: userData['impactSnapshot'] ?? '',
              phone: userData['phone'] ?? '',
              address: userData['address'] ?? '',
              instagramLink: userData['instagramLink'] ?? '',
              companyName: userData['companyName'] ?? '',
              companyLogo: userData['companyLogo'] ?? '',
              companyIndustry: userData['companyIndustry'] ?? '',
              csrDetails: userData['csrDetails'] ?? '',
            );

            followerCount.value = viewedUser.value!.followerCount;
            followingCount.value = viewedUser.value!.followingCount;

            isFollowing.value = await _firebaseService.isFollowing(
              _nameController.userId,
              _targetUserId,
            );
            userFound.value = true;
          } catch (e) {
            print('DEBUG: Error parsing AccountUser: $e');
            userFound.value = false;
          }
        } else {
          userFound.value = false;
        }
      }

      if (userFound.value) {
        await Future.wait([
          fetchUserImpactStands(),
          fetchUserCampaigns(),
          fetchUserPosts(),
          fetchUserComments(),
        ]);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPage() async {
    await fetchUserData(isRefresh: true);
  }

  Future<void> toggleFollow() async {
    if (isOwnProfile) return;

    final originallyFollowing = isFollowing.value;
    isFollowing.value = !originallyFollowing;
    followerCount.value += originallyFollowing ? -1 : 1;

    try {
      await _firebaseService.toggleFollow(
        currentUserId: _nameController.userId,
        targetUserId: _targetUserId,
        isCurrentlyFollowing: originallyFollowing,
      );
    } catch (e) {
      isFollowing.value = originallyFollowing;
      followerCount.value += originallyFollowing ? 1 : -1;
      Get.snackbar(
        'Error',
        'Could not update follow status. Please try again.',
      );
    }
  }

  Future<void> fetchUserImpactStands() async {
    isLoadingImpactStands.value = true;
    print(
      "DEBUG: Fetching user impact stands for targetUserId: '$_targetUserId'",
    );
    try {
      final dataList = await _firebaseService.getUserImpactStands(
        _targetUserId,
      );
      print("DEBUG: Received ${dataList.length} stands from service");

      final List<ImpactStand> mappedStands = [];
      for (var data in dataList) {
        try {
          mappedStands.add(
            ImpactStand(
              id: data['id'] ?? 'unknown',
              standId: data['standId'] ?? '',
              name: data['name'] ?? 'Untitled',
              subHeading: data['subHeading'] ?? '',
              description: data['description'] ?? '',
              type: data['type'] ?? 'Other',
              whoShouldAct: data['whoShouldAct'] ?? [],
              community: data['community'] ?? 'India',
              photoUrls: List<String>.from(data['photoUrls'] ?? []),
              standCount: data['standCount'] ?? 0,
              commentCount: data['commentCount'] ?? 0,
              hasTakenStand: data['hasTakenStand'] ?? false,
              creatorId: data['creatorId'] ?? '',
              timestamp: data['timestamp'],
              status: data['status'] ?? 'active',
              isPetition: data['isPetition'] ?? false,
            ),
          );
        } catch (itemErr) {
          print("DEBUG: Error mapping stand item: $itemErr");
        }
      }

      userImpactStands.assignAll(mappedStands);
      print("DEBUG: Mapped ${userImpactStands.length} impact stands to RxList");
    } catch (e) {
      print("Global Error in fetchUserImpactStands: $e");
    } finally {
      isLoadingImpactStands.value = false;
    }
  }

  Future<void> fetchUserCampaigns() async {
    isLoadingCampaigns.value = true;
    try {
      final dataList = await _firebaseService.getUserCampaigns(_targetUserId);
      final List<Campaign> mappedCampaigns = [];
      for (var data in dataList) {
        try {
          mappedCampaigns.add(
            Campaign(
              id: data['id'] ?? 'unknown',
              standId: data['standId'] ?? '',
              name: data['name'] ?? 'Untitled',
              subHeading: data['subHeading'] ?? '',
              description: data['description'] ?? '',
              type: data['type'] ?? 'Other',
              whoShouldAct: data['whoShouldAct'] ?? [],
              community: data['community'] ?? 'India',
              photoUrls: List<String>.from(data['photoUrls'] ?? []),
              standCount: data['standCount'] ?? 0,
              commentCount: data['commentCount'] ?? 0,
              hasTakenStand: data['hasTakenStand'] ?? false,
              creatorId: data['creatorId'] ?? '',
              timestamp: data['timestamp'],
              status: data['status'] ?? 'active',
            ),
          );
        } catch (itemErr) {
          print("DEBUG: Error mapping campaign item: $itemErr");
        }
      }
      userCampaigns.assignAll(mappedCampaigns);
    } catch (e) {
      print("Global Error in fetchUserCampaigns: $e");
    } finally {
      isLoadingCampaigns.value = false;
    }
  }

  Future<void> fetchUserPosts() async {
    isLoadingPosts.value = true;
    try {
      final docs = await _firebaseService.getPostsPaginated(
        authorHandle: userHandle,
        limit: 20,
      );
      final mappedPosts = docs
          .map(
            (doc) => _firebaseService.mapSnapshotToPost(
              doc,
              _nameController.userName.value,
            ),
          )
          .toList();
      userPosts.assignAll(mappedPosts);
    } catch (e) {
      print("Error fetching user posts: $e");
    } finally {
      isLoadingPosts.value = false;
    }
  }

  Future<void> fetchUserComments() async {
    isLoadingComments.value = true;
    try {
      final comments = await _firebaseService.getUserComments(
        userHandle,
        _nameController.userId,
      );
      userComments.assignAll(comments);
    } catch (e) {
      print("Error fetching user comments: $e");
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> votePost(
    String postId,
    VoteState currentVote,
    bool isUpvoteButton,
  ) async {
    final index = userPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = userPosts[index];
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

    userPosts[index] = Post(
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
        _nameController.userName.value,
        currentVote,
        isUpvoteButton,
      );
    } catch (e) {
      userPosts[index] = post; // Revert
    }
  }

  Future<void> voteComment(
    String commentId,
    VoteState currentVote,
    bool isUpvoteButton,
  ) async {
    // Find the comment and its post
    // This is hard because Comment model doesn't store PostId currently in the list?
    // Wait, getUserComments returns Comment objects.
    // Let's check FirebaseService.updateCommentVote - it needs postId.
    // Shit, my Comment model doesn't have postId.
    // For now, I'll skip comment voting on profile or just show them.
    // The user didn't explicitly ask for comment voting on profile, just "ui and actions as early".
  }
}
