import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:oulta/features/data/account/repositories/account_repository_impl.dart';
import 'package:oulta/features/data/account/models/account_user_model.dart';
import 'package:oulta/features/domain/account/entities/account_user.dart';
import 'package:oulta/features/domain/account/usecases/account_usecases.dart';

enum ScreenState { loading, loggedOut, needsProfileSetup, loggedIn }

class NameController extends GetxController {
  // --- Dependencies ---
  late final AccountUseCases _useCases;

  // --- State ---
  var screenState = ScreenState.loading.obs;

  // Rx Fields (kept for UI compatibility)
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhotoUrl = ''.obs;
  var tagline = ''.obs;
  var location = ''.obs;
  var userState = ''.obs;
  var userDistrict = ''.obs;
  var userPlace = ''.obs;
  var website = ''.obs;
  var dharma = 0.obs;
  var followerCount = 0.obs;
  var followingCount = 0.obs;
  var earnedBadgeIds = <String>[].obs;
  var takenStandIds = <String>[].obs;
  var joinedCommunities = <String>['india'].obs;
  var isVerrified = false.obs;
  var profileType = 'user'.obs;

  // NGO fields
  var ngoName = ''.obs;
  var ngoMission = ''.obs;
  var ngoLogo = ''.obs;
  var registrationNumber = ''.obs;
  var contactInfo = ''.obs;
  var featuredCampaign = ''.obs;
  var legalType = ''.obs;
  var registrationDate = ''.obs;
  var focusAreas = <String>[].obs;
  var shortAbout = ''.obs;
  var keyProgram = ''.obs;
  var impactSnapshot = ''.obs;
  var phone = ''.obs;
  var address = ''.obs;
  var instagramLink = ''.obs;
 
  // Company fields
  var companyName = ''.obs;
  var companyLogo = ''.obs;
  var companyIndustry = ''.obs;
  var csrDetails = ''.obs;

  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var isNameSet = false.obs;

  // Real-time Firestore user doc listener subscription
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  // Internal cache
  AccountUser? _currentUser;
  final Rx<AccountUser?> currentUserRx = Rx<AccountUser?>(null);
  String get userId => _currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    // In a real app, use Dependency Injection (Bindings)
    final repo = AccountRepositoryImpl();
    _useCases = AccountUseCases(repo);

    _useCases.authState.listen((user) {
      _handleAuthState(user);
    });
  }

  @override
  void onClose() {
    _userDocSubscription?.cancel();
    super.onClose();
  }

  void _handleAuthState(AccountUser? user) {
    _userDocSubscription?.cancel();
    _userDocSubscription = null;

    if (user == null) {
      _clearUserData();
      screenState.value = ScreenState.loggedOut;
    } else {
      _currentUser = user;
      _updateRxFields(user);
      isLoggedIn.value = true;
      screenState.value = ScreenState.loggedIn;

      // Listen to the user document in real-time to immediately reflect updates (e.g. Dharma Points)
      _userDocSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null) {
            final freshUser = AccountUserModel.fromMap(data, user.uid);
            _currentUser = freshUser;
            _updateRxFields(freshUser);
          }
        }
      }, onError: (e) {
        debugPrint('Error in user doc real-time subscription: $e');
      });
    }
  }

  void _updateRxFields(AccountUser user) {
    userName.value = user.name;
    userEmail.value = user.email;
    userPhotoUrl.value = user.photoUrl;
    tagline.value = user.tagline;
    location.value = user.location.toString();
    userState.value = user.location.state;
    userDistrict.value = user.location.district;
    userPlace.value = user.location.place;
    website.value = user.website;
    dharma.value = user.dharma;
    followerCount.value = user.followerCount;
    followingCount.value = user.followingCount;
    earnedBadgeIds.value = user.earnedBadgeIds;
    takenStandIds.value = user.takenStandIds;
    joinedCommunities.value = user.joinedCommunities.contains('india')
        ? user.joinedCommunities
        : ['india', ...user.joinedCommunities];
    isVerrified.value = user.isVerified;
    profileType.value = user.profileType;

    ngoName.value = user.ngoName;
    ngoMission.value = user.ngoMission;
    ngoLogo.value = user.ngoLogo;
    registrationNumber.value = user.registrationNumber;
    contactInfo.value = user.contactInfo;
    featuredCampaign.value = user.featuredCampaign;
    legalType.value = user.legalType;
    registrationDate.value = user.registrationDate;
    focusAreas.value = user.focusAreas;
    shortAbout.value = user.shortAbout;
    keyProgram.value = user.keyProgram;
    impactSnapshot.value = user.impactSnapshot;
    phone.value = user.phone;
    address.value = user.address;
    instagramLink.value = user.instagramLink;
 
    companyName.value = user.companyName;
    companyLogo.value = user.companyLogo;
    companyIndustry.value = user.companyIndustry;
    csrDetails.value = user.csrDetails;

    // Update currentUserRx LAST so listeners see updated fields
    print(
      "Updating user ${user.uid} with ${user.takenStandIds.length} taken stands",
    );
    currentUserRx.value = user;
  }

  void _clearUserData() {
    _currentUser = null;
    userName.value = '';
    userEmail.value = '';
    userPhotoUrl.value = '';
    tagline.value = '';
    location.value = '';
    userState.value = '';
    userDistrict.value = '';
    userPlace.value = '';
    website.value = '';
    isLoggedIn.value = false;
    isNameSet.value = false;
    isVerrified.value = false;
    dharma.value = 0;
    followerCount.value = 0;
    followingCount.value = 0;
    earnedBadgeIds.clear();
    takenStandIds.clear();
    joinedCommunities.value = ['india'];
    profileType.value = 'user';
    ngoName.value = '';
    ngoMission.value = '';
    ngoLogo.value = '';
    registrationNumber.value = '';
    contactInfo.value = '';
    featuredCampaign.value = '';
    legalType.value = '';
    registrationDate.value = '';
    focusAreas.clear();
    shortAbout.value = '';
    keyProgram.value = '';
    impactSnapshot.value = '';
    phone.value = '';
    address.value = '';
    instagramLink.value = '';
 
    companyName.value = '';
    companyLogo.value = '';
    companyIndustry.value = '';
    csrDetails.value = '';

    // Explicitly nullify reactive user so listeners fire on logout
    currentUserRx.value = null;
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final user = await _useCases.signInWithGoogle();
      if (user != null) {
        _handleAuthState(user);
        Get.snackbar(
          'Success',
          'Signed in as ${user.email}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Sign in failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _useCases.signOut();
      _clearUserData();
    } catch (e) {
      Get.snackbar('Error', 'Sign out failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Re-fetch data manually if needed
  Future<void> loadUserData() async {
    if (_currentUser == null) return;
    try {
      final user = await _useCases.getUser(_currentUser!.uid);
      if (user != null) {
        _currentUser = user; // Update local cache
        _updateRxFields(user);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> saveName(String name) async {
    if (name.trim().isEmpty || _currentUser == null) return;
    try {
      isLoading.value = true;
      await _useCases.updateName(_currentUser!.uid, name);
      userName.value = name.trim();
      Get.snackbar('Success', 'Name saved!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save name: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile(
    String name,
    String newTagline,
    UserLocation newLocation,
  ) async {
    if (_currentUser == null) return;
    try {
      isLoading.value = true;

      final updatedUser = AccountUser(
        uid: _currentUser!.uid,
        name: name,
        email: _currentUser!.email,
        photoUrl: _currentUser!.photoUrl,
        tagline: newTagline,
        location: newLocation,
        website: _currentUser!.website,
        isVerified: _currentUser!.isVerified,
        dharma: _currentUser!.dharma,
        followerCount: _currentUser!.followerCount,
        followingCount: _currentUser!.followingCount,
        earnedBadgeIds: _currentUser!.earnedBadgeIds,
        takenStandIds: _currentUser!.takenStandIds,
        profileType: _currentUser!.profileType,
        ngoName: _currentUser!.ngoName,
        ngoMission: _currentUser!.ngoMission,
        ngoLogo: _currentUser!.ngoLogo,
        registrationNumber: _currentUser!.registrationNumber,
        contactInfo: _currentUser!.contactInfo,
        featuredCampaign: _currentUser!.featuredCampaign,
        legalType: _currentUser!.legalType,
        registrationDate: _currentUser!.registrationDate,
        focusAreas: _currentUser!.focusAreas,
        shortAbout: _currentUser!.shortAbout,
        keyProgram: _currentUser!.keyProgram,
        impactSnapshot: _currentUser!.impactSnapshot,
        phone: _currentUser!.phone,
        address: _currentUser!.address,
        instagramLink: _currentUser!.instagramLink,
      );

      await _useCases.updateProfile(updatedUser);

      // Update local state
      userName.value = name;
      tagline.value = newTagline;
      location.value = newLocation.toString();
      userState.value = newLocation.state;
      userDistrict.value = newLocation.district;
      userPlace.value = newLocation.place;

      Get.snackbar(
        'Success',
        'Profile updated!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadProfileImage() async {
    await _pickAndUploadImage(isNgoLogo: false);
  }

  Future<void> pickAndUploadNgoLogo() async {
    await _pickAndUploadImage(isNgoLogo: true);
  }

  Future<void> _pickAndUploadImage({required bool isNgoLogo}) async {
    if (_currentUser == null) return;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 25,
      );

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        isLoading.value = true;
        String newUrl = await _useCases.uploadImage(
          _currentUser!.uid,
          file,
          isNgo: isNgoLogo,
        );

        if (isNgoLogo) {
          ngoLogo.value = newUrl;
        } else {
          userPhotoUrl.value = newUrl;
        }

        Get.snackbar(
          'Success',
          '${isNgoLogo ? 'NGO Logo' : 'Profile photo'} updated!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveNgoProfile(Map<String, dynamic> ngoData) async {
    if (_currentUser == null) return;
    // Validate
    final requiredFields = {
      'ngoName': ngoData['ngoName'],
      'legalType': ngoData['legalType'],
      'registrationNumber': ngoData['registrationNumber'],
      'contactInfo': ngoData['contactInfo'],
      'phone': ngoData['phone'],
    };
    var missing = requiredFields.entries
        .where(
          (e) => (e.value is String
              ? (e.value as String).trim().isEmpty
              : e.value == null),
        )
        .map((e) => e.key)
        .toList();

    if (missing.isNotEmpty) {
      Get.snackbar(
        'Error',
        'Missing fields: ${missing.join(", ")}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      // We need to construct an updated user object
      // This is a bit manual without copyWith, but adhering to the architectural separation

      final updatedUser = AccountUser(
        uid: _currentUser!.uid,
        name: _currentUser!.name,
        email: _currentUser!.email,
        photoUrl: _currentUser!.photoUrl,
        tagline: _currentUser!.tagline,
        location: _currentUser!.location,
        website: _currentUser!.website,
        isVerified: _currentUser!.isVerified,
        dharma: _currentUser!.dharma,
        followerCount: _currentUser!.followerCount,
        followingCount: _currentUser!.followingCount,
        earnedBadgeIds: _currentUser!.earnedBadgeIds,
        takenStandIds: _currentUser!.takenStandIds,
        profileType: 'ngo', // Force NGO type
        ngoName: ngoData['ngoName'] ?? '',
        ngoMission:
            ngoData['ngoMission'] ??
            '', // Assuming this might be passed or kept
        ngoLogo: _currentUser!.ngoLogo,
        registrationNumber: ngoData['registrationNumber'] ?? '',
        contactInfo: ngoData['contactInfo'] ?? '',
        featuredCampaign: ngoData['featuredCampaign'] ?? '',
        legalType: ngoData['legalType'] ?? '',
        registrationDate: ngoData['registrationDate'] ?? '',
        focusAreas: ngoData['focusAreas'] != null
            ? List<String>.from(ngoData['focusAreas'])
            : _currentUser!.focusAreas,
        shortAbout: ngoData['shortAbout'] ?? '',
        keyProgram: ngoData['keyProgram'] ?? '',
        impactSnapshot: ngoData['impactSnapshot'] ?? '',
        phone: ngoData['phone'] ?? '',
        address: ngoData['address'] ?? '',
        instagramLink: ngoData['instagramLink'] ?? '',
      );

      await _useCases.updateProfile(updatedUser);
      _updateRxFields(updatedUser);
      _currentUser = updatedUser;

      Get.snackbar(
        'Success',
        'NGO profile updated!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update NGO profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showNameDialog({bool isEdit = false}) {
    final nameEditingController = TextEditingController(
      text: isEdit ? userName.value : '',
    );
    Get.defaultDialog(
      title: isEdit ? 'Edit Name' : 'Enter Your Name',
      content: TextField(controller: nameEditingController),
      textConfirm: isEdit ? 'Update' : 'Save',
      onConfirm: () {
        Get.back();
        saveName(nameEditingController.text);
      },
    );
  }
}
