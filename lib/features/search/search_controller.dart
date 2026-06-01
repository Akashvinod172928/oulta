import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oulta/features/data/social/services/firebase_service.dart';

class UserSearchController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxString query = ''.obs;
  final RxList<QueryDocumentSnapshot> searchResults =
      <QueryDocumentSnapshot>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;

  // Added controller to sync with the TextField in the UI
  final TextEditingController textEditingController = TextEditingController();

  Worker? _debounceWorker;

  @override
  void onInit() {
    super.onInit();
    // Use debounce to wait for 300ms after the last change before searching
    _debounceWorker = debounce(query, (String val) {
      _performSearch(val);
    }, time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    _debounceWorker?.dispose();
    textEditingController.dispose();
    super.onClose();
  }

  void searchUsers(String value) {
    query.value = value;
  }

  void _performSearch(String value) {
    final trimmedValue = value.trim();

    // If empty or too short, reset
    if (trimmedValue.isEmpty || trimmedValue.length < 1) {
      searchResults.clear();
      hasSearched.value = false;
      isLoading.value = false;
      return;
    }

    // Clean query from prefixes like "u/", "ngo/", or "c/"
    String processed = trimmedValue.toLowerCase();
    if (processed.startsWith('u/')) {
      processed = processed.substring(2);
    } else if (processed.startsWith('ngo/')) {
      processed = processed.substring(4);
    } else if (processed.startsWith('c/')) {
      processed = processed.substring(2);
    }
    
    if (processed.isEmpty) return;

    isLoading.value = true;
    hasSearched.value = true;

    print("Searching for users with query: '$processed'");

    _firebaseService
        .searchUsers(processed)
        .then((users) {
          print("Search results found: ${users.length}");
          searchResults.value = users;
        })
        .catchError((error) {
          print("Search error: $error");
          Get.snackbar('Error', 'Error searching users: $error');
        })
        .whenComplete(() {
          isLoading.value = false;
        });
  }

  void clearSearch() {
    query.value = '';
    textEditingController.clear();
    searchResults.clear();
    hasSearched.value = false;
    isLoading.value = false;
  }
}
