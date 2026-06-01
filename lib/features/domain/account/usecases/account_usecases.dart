import '../entities/account_user.dart';
import '../repositories/account_repository.dart';
import 'dart:io';

class AccountUseCases {
  final AccountRepository repository;

  AccountUseCases(this.repository);

  Future<AccountUser?> signInWithGoogle() => repository.signInWithGoogle();
  Future<void> signOut() => repository.signOut();
  Future<AccountUser?> getUser(String uid) => repository.loadUserData(uid);
  Stream<AccountUser?> get authState => repository.onAuthStateChanged;

  Future<void> updateName(String uid, String name) =>
      repository.updateName(uid, name);
  Future<void> updateProfile(AccountUser user) =>
      repository.updateProfile(user);
  Future<String> uploadImage(String uid, File file, {required bool isNgo}) =>
      repository.uploadProfileImage(uid, file, isNgoLogo: isNgo);
}
