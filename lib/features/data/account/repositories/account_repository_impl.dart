import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:oulta/features/domain/account/entities/account_user.dart';
import 'package:oulta/features/domain/account/repositories/account_repository.dart';
import 'package:oulta/features/data/account/models/account_user_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Stream<AccountUser?> get onAuthStateChanged {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await loadUserData(firebaseUser.uid);
    });
  }

  @override
  Future<AccountUser?> signInWithGoogle() async {
    try {
      User? user;
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final userCred = await _auth.signInWithPopup(provider);
        user = userCred.user;
      } else {
        await _googleSignIn.initialize(
          serverClientId:
              "976555914873-mvf98mrk3su939di6mrajo4u3doqgn21.apps.googleusercontent.com",
        );
        final account = await _googleSignIn.authenticate();
        final auth = account.authentication;
        final cred = GoogleAuthProvider.credential(idToken: auth.idToken);
        final userCred = await _auth.signInWithCredential(cred);
        user = userCred.user;
      }

      if (user != null) {
        await _ensureUserExists(user);
        return await loadUserData(user.uid);
      }
    } catch (e) {
      debugPrint("SignIn error: $e");
      rethrow;
    }
    return null;
  }

  Future<void> _ensureUserExists(User user) async {
    final docRefs = _usersCollection.doc(user.uid);
    final docSnap = await docRefs.get();
    if (!docSnap.exists) {
      // Create basic user
      await docRefs.set({
        'name': user.displayName ?? '',
        'name_lowercase': (user.displayName ?? '').toLowerCase(),
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'provider': 'google',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Default fields (matching controller)
        'profileType': 'user',
        'dharma': 0,
        'followerCount': 0,
        'followingCount': 0,
        'badges': <String>[],
        'takenStandIds': <String>[],
        'isVerrified': false,
      }, SetOptions(merge: true));
    } else {
      // Just ensure email/photo are up to date if needed, or do nothing
      // controller logic did a merge every time, we can mimic that
      await docRefs.set({
        'email': user.email ?? '',
        'photoUrl':
            user.photoURL ?? '', // optionally update photo from google on login
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<AccountUser?> loadUserData(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return AccountUserModel.fromMap(
          doc.data() as Map<String, dynamic>,
          uid,
        );
      }
      return null;
    } catch (e) {
      debugPrint("LoadUserData error: $e");
      return null;
    }
  }

  @override
  Future<void> updateProfile(AccountUser user) async {
    final model = AccountUserModel.fromEntity(user);
    await _usersCollection.doc(user.uid).update(model.toMap());
  }

  @override
  Future<void> updateName(String uid, String name) async {
    await _usersCollection.doc(uid).set({
      'name': name.trim(),
      'name_lowercase': name.trim().toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<String> uploadProfileImage(
    String uid,
    File file, {
    required bool isNgoLogo,
  }) async {
    // Logic from Controller: Base64 encoding
    List<int> imageBytes = await file.readAsBytes();
    String base64Image = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';

    String fieldToUpdate = isNgoLogo ? 'ngoLogo' : 'photoUrl';
    await _usersCollection.doc(uid).update({
      fieldToUpdate: base64Image,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return base64Image;
  }
}
