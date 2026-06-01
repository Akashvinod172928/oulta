import 'dart:io';
import '../entities/account_user.dart';

abstract class AccountRepository {
  Future<AccountUser?> signInWithGoogle();
  Future<void> signOut();
  Future<AccountUser?> loadUserData(String uid);
  Future<void> updateProfile(AccountUser user);
  Future<void> updateName(String uid, String name);
  Future<String> uploadProfileImage(
    String uid,
    File file, {
    required bool isNgoLogo,
  });
  Stream<AccountUser?> get onAuthStateChanged;
  String? get currentUserId;
}
