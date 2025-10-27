import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class NameController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn.instance;

  // Reactive variables
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhotoUrl = ''.obs;
  var isLoading = false.obs;
  var isNameSet = false.obs;
  var isLoggedIn = false.obs;

  var dharma = 0.obs;

  String get userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _activityCollection => _firestore.collection('activity');

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      isLoading.value = true;
      if (_auth.currentUser != null) {
        await loadUserData();
      } else {
        _clearUserData();
      }
    } catch (e) {
      _clearUserData();
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Sign in with Google (same as AuthService version)
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      if (kIsWeb) {
        // ✅ Web flow: use Firebase signInWithPopup
        final provider = GoogleAuthProvider();
        final userCred = await _auth.signInWithPopup(provider);
        final user = userCred.user;

        if (user != null) {
          await _saveUserToFirestore(user);
          await loadUserData();
          Get.snackbar('Success', 'Signed in as ${user.email}',
              backgroundColor: Colors.green, colorText: Colors.white);
        }
      } else {
        // ✅ Android/iOS flow: your existing working logic
        await _googleSignIn.initialize(
          serverClientId:
          "761223518670-amh87uftt5413sulvkep7n6entbo9qbc.apps.googleusercontent.com",
        );

        final account = await _googleSignIn.authenticate();
        if (account == null) return;

        final auth = account.authentication;

        final cred = GoogleAuthProvider.credential(
          idToken: auth.idToken,
          // accessToken: auth.accessToken,
        );

        final userCred = await _auth.signInWithCredential(cred);
        final user = userCred.user;

        if (user != null) {
          await _saveUserToFirestore(user);
          await loadUserData();
          Get.snackbar('Success', 'Signed in as ${user.email}',
              backgroundColor: Colors.green, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Sign in failed: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      print("SignIn error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _auth.signOut();
      await _googleSignIn.signOut();
      _clearUserData();
      Get.snackbar('Signed Out', 'You have been signed out');
    } catch (e) {
      Get.snackbar('Error', 'Sign out failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _clearUserData() {
    userName.value = '';
    userEmail.value = '';
    userPhotoUrl.value = '';
    isNameSet.value = false;
    isLoggedIn.value = false;
    dharma.value = 0;

  }

  Future<void> _saveUserToFirestore(User user) async {
    try {
      await _usersCollection.doc(user.uid).set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'provider': 'google',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 🔹 Create activity record if not exists
      final activityDoc = await _activityCollection.doc(user.uid).get();
      if (!activityDoc.exists) {
        await _activityCollection.doc(user.uid).set({
          'dharma': 0,
        });
      }
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  Future<void> loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _clearUserData();
        return;
      }

      final doc = await _usersCollection.doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        userName.value = data['name'] ?? user.displayName ?? '';
      } else {
        userName.value = user.displayName ?? '';
      }

      userEmail.value = user.email ?? '';
      userPhotoUrl.value = user.photoURL ?? '';
      isNameSet.value = userName.value.isNotEmpty;
      isLoggedIn.value = true;

      // 🔹 Load dharma
      final activityDoc = await _activityCollection.doc(user.uid).get();
      if (activityDoc.exists) {
        final data = activityDoc.data() as Map<String, dynamic>;
        dharma.value = data['dharma'] ?? 0;
      } else {
        dharma.value = 0;
      }
    } catch (e) {
      _clearUserData();
    }
  }

  /// Save a custom name into Firestore
  Future<void> saveName(String name) async {
    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your name');
      return;
    }

    try {
      isLoading.value = true;
      await _usersCollection.doc(userId).set({
        'name': name.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      userName.value = name.trim();
      isNameSet.value = true;

      Get.snackbar('Success', 'Name saved!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save name: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showNameDialog({bool isEdit = false}) {
    final nameController =
    TextEditingController(text: isEdit ? userName.value : '');

    Get.defaultDialog(
      title: isEdit ? 'Edit Name' : 'Enter Your Name',
      content: TextField(controller: nameController),
      textConfirm: isEdit ? 'Update' : 'Save',
      onConfirm: () {
        Get.back();
        saveName(nameController.text);
      },
    );
  }


  // 🔹 Update Dharma
  Future<void> updateDharma(int points) async {
    try {
      final ref = _activityCollection.doc(userId);
      await ref.update({
        'dharma': FieldValue.increment(points),
      });
      dharma.value += points;
    } catch (e) {
      debugPrint("Error updating dharma: $e");
    }
  }
}