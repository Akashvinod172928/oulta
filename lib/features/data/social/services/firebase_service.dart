import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oulta/features/presentation/social/comments/widgets/comment_card.dart';
import 'package:oulta/features/presentation/social/widgets/post_card.dart';

class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseService({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  static final currentCommunity =
      'kerala'.obs; // Single source of truth static variable

  String _generateStandId(String prefix) {
    final now = DateTime.now();
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final yy = (now.year % 100).toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    return '$prefix-$dd$mm$yy-$hh$min$ss';
  }

  // --- Upload Methods ---
  Future<List<String>> uploadImpactStandImages(List<dynamic> images) async {
    print('DEBUG: uploadImpactStandImages called with ${images.length} images');
    List<String> downloadUrls = [];
    for (int i = 0; i < images.length; i++) {
      var image = images[i];
      String fileName =
          'impact_stands/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      print('DEBUG: Uploading image $i to path: $fileName');
      Reference ref = _storage.ref().child(fileName);

      UploadTask uploadTask;
      try {
        if (kIsWeb) {
          if (image is XFile) {
            Uint8List bytes = await image.readAsBytes();
            print('DEBUG: Read ${bytes.length} bytes from XFile (Web)');
            uploadTask = ref.putData(
              bytes,
              SettableMetadata(contentType: 'image/jpeg'),
            );
          } else if (image is Uint8List) {
            print('DEBUG: Uploading Uint8List (Web)');
            uploadTask = ref.putData(
              image,
              SettableMetadata(contentType: 'image/jpeg'),
            );
          } else {
            print('DEBUG: Unknown image type for Web: ${image.runtimeType}');
            continue;
          }
        } else {
          if (image is File) {
            print('DEBUG: Uploading File (Mobile)');
            uploadTask = ref.putFile(image);
          } else if (image is XFile) {
            print('DEBUG: Uploading XFile via putData (Desktop/Mobile)');
            Uint8List bytes = await image.readAsBytes();
            uploadTask = ref.putData(
              bytes,
              SettableMetadata(contentType: 'image/jpeg'),
            );
          } else {
            print('DEBUG: Unknown image type for Mobile/Desktop: ${image.runtimeType}');
            continue;
          }
        }

        print('DEBUG: Waiting for upload task to complete...');
        TaskSnapshot snapshot = await uploadTask;
        print('DEBUG: Upload completed. Bytes transferred: ${snapshot.bytesTransferred}');
        
        String downloadUrl = await ref.getDownloadURL();
        print('DEBUG: Got download URL: $downloadUrl');
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print('DEBUG: ERROR during image upload at index $i: $e');
        rethrow;
      }
    }
    print('DEBUG: Finished uploading all images. Returning ${downloadUrls.length} URLs');
    return downloadUrls;
  }

  void switchCommunity(String id) {
    currentCommunity.value = id;
    print('Switched to: $id');
  }

  // --- Helper Methods ---
  double _calculateHotness(int score, DateTime timestamp) {
    final order = log(max(score.abs(), 1)) / log(10);
    final sign = score.sign;
    final seconds = timestamp.millisecondsSinceEpoch / 1000 - 1134028003;
    return sign * order + seconds / 45000;
  }

  Future<void> _runVoteTransaction(
    DocumentReference ref,
    String userId,
    VoteState currentVote,
    bool isUpvoteButton,
  ) {
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw Exception("Document does not exist!");
      final data = snapshot.data()! as Map<String, dynamic>;

      List<String> upvoters = (data['upvoters'] is List)
          ? List<String>.from(data['upvoters'].whereType<String>())
          : [];
      List<String> downvoters = (data['downvoters'] is List)
          ? List<String>.from(data['downvoters'].whereType<String>())
          : [];

      // DERIVE TRUE STATE from DB (Source of Truth)
      // This prevents race conditions or UI sync issues.
      VoteState realCurrentVote = VoteState.none;
      if (upvoters.contains(userId)) {
        realCurrentVote = VoteState.up;
      } else if (downvoters.contains(userId)) {
        realCurrentVote = VoteState.down;
      }

      // Calculate Dharma Delta based on TRUE state
      int dharmaDelta = 0;

      if (isUpvoteButton) {
        if (realCurrentVote == VoteState.up) {
          // Up -> None (Toggle Off)
          upvoters.remove(userId);
          dharmaDelta = -1;
        } else {
          // None -> Up OR Down -> Up
          if (realCurrentVote == VoteState.down) {
            dharmaDelta = 2; // Down -> Up
            downvoters.remove(userId);
          } else {
            dharmaDelta = 1; // None -> Up
          }
          upvoters.add(userId);
        }
      } else {
        // Downvote Button
        if (realCurrentVote == VoteState.down) {
          // Down -> None (Toggle Off)
          downvoters.remove(userId);
          dharmaDelta = 1; // Removing negative is positive
        } else {
          // None -> Down OR Up -> Down
          if (realCurrentVote == VoteState.up) {
            dharmaDelta = -2; // Up -> Down
            upvoters.remove(userId);
          } else {
            dharmaDelta = -1; // None -> Down
          }
          downvoters.add(userId);
        }
      }

      final newScore = upvoters.length - downvoters.length;

      DateTime timestamp;
      if (data['timestamp'] is Timestamp) {
        timestamp = (data['timestamp'] as Timestamp).toDate();
      } else {
        timestamp = DateTime.now();
      }

      final newHotness = _calculateHotness(newScore, timestamp);
      transaction.update(ref, {
        'upvoters': upvoters,
        'downvoters': downvoters,
        'score': newScore,
        'hotness': newHotness,
      });

      // Update Author Dharma
      // 1. Check if it's a post
      if (ref.path.startsWith('posts') && dharmaDelta != 0) {
        final String authorHandle = data['authorHandle'] ?? '';
        // 2. Check no self-dharma
        if (authorHandle.isNotEmpty && authorHandle != userId) {
          // 3. Find User Doc by Handle (Query) using separate read (since we don't have UID ref)
          // We must do this query inside runTransaction's async block.
          // Note: Queries are not transactional reads unless we verify result,
          // but specifically we just need the Ref to increment field.
          final userQuery = await _firestore
              .collection('users')
              .where('name', isEqualTo: authorHandle)
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            final userDocRef = userQuery.docs.first.reference;
            transaction.update(userDocRef, {
              'dharma': FieldValue.increment(dharmaDelta),
            });
          }
        }
      }
    });
  }

  Future<void> updateDharmaPoints(
    String userId,
    int points,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'dharma': FieldValue.increment(points),
      });
    } catch (e) {
      print('Error in updateDharmaPoints: $e');
      rethrow;
    }
  }

  // --- User & Follow Methods ---
  Future<DocumentSnapshot?> getUserByHandle(String handle) async {
    // Use name_lowercase — this field is allowed by Firestore security rules
    // (the search feature also queries on this same field successfully)
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('name_lowercase', isEqualTo: handle.toLowerCase())
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
    } catch (e) {
      print('getUserByHandle error: $e');
      return null;
    }
  }

  Future<List<QueryDocumentSnapshot>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    final trimmedQuery = query.trim();
    final lowerQuery = trimmedQuery.toLowerCase();
    
    // Prefix ranges
    final String endRangeLower = lowerQuery + '\uf8ff';
    final String endRangeOriginal = trimmedQuery + '\uf8ff';
    
    final List<QuerySnapshot> allSnapshots = [];

    // Helper to safely execute queries and collect snapshots
    Future<void> runSearchQuery(Query q) async {
      try {
        final snap = await q.get();
        allSnapshots.add(snap);
      } catch (e) {
        // Log individual query failures (e.g., missing index) 
        // but don't crash the entire search
        print("Search sub-query failed: $e");
      }
    }

    try {
      // Execute all search facets in parallel for speed
      await Future.wait([
        // 1. Preferred Search: Case-insensitive on name_lowercase
        runSearchQuery(_firestore
            .collection('users')
            .where('name_lowercase', isGreaterThanOrEqualTo: lowerQuery)
            .where('name_lowercase', isLessThan: endRangeLower)
            .limit(10)),
            
        // 2. Legacy/Exact Fallback: Case-sensitive on original name
        runSearchQuery(_firestore
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: trimmedQuery)
            .where('name', isLessThan: endRangeOriginal)
            .limit(10)),

        // 3. NGO Search: Case-insensitive on ngoName_lowercase
        runSearchQuery(_firestore
            .collection('users')
            .where('ngoName_lowercase', isGreaterThanOrEqualTo: lowerQuery)
            .where('ngoName_lowercase', isLessThan: endRangeLower)
            .limit(10)),
            
        // 4. Exact Email Match
        runSearchQuery(_firestore
            .collection('users')
            .where('email', isEqualTo: trimmedQuery)
            .limit(5)),
      ]);

      // Merge and deduplicate results by document ID
      final Map<String, QueryDocumentSnapshot> uniqueDocs = {};
      for (var snapshot in allSnapshots) {
        for (var doc in snapshot.docs) {
          uniqueDocs[doc.id] = doc;
        }
      }

      return uniqueDocs.values.toList();
    } catch (e) {
      print("Error in searchUsers overall: $e");
      return [];
    }
  }

  Future<DocumentSnapshot?> getActivityForUser(String userId) async {
    final doc = await _firestore.collection('activity').doc(userId).get();
    return doc.exists ? doc : null;
  }

  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    if (currentUserId.isEmpty) return false;
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId)
        .get();
    return doc.exists;
  }

  Future<void> toggleFollow({
    required String currentUserId,
    required String targetUserId,
    required bool isCurrentlyFollowing,
  }) async {
    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final targetUserRef = _firestore.collection('users').doc(targetUserId);
    final followingRef = currentUserRef
        .collection('following')
        .doc(targetUserId);
    final followersRef = targetUserRef
        .collection('followers')
        .doc(currentUserId);

    return _firestore.runTransaction((transaction) async {
      if (isCurrentlyFollowing) {
        transaction.delete(followingRef);
        transaction.delete(followersRef);
        transaction.update(currentUserRef, {
          'followingCount': FieldValue.increment(-1),
        });
        transaction.update(targetUserRef, {
          'followerCount': FieldValue.increment(-1),
        });
      } else {
        transaction.set(followingRef, {
          'timestamp': FieldValue.serverTimestamp(),
        });
        transaction.set(followersRef, {
          'timestamp': FieldValue.serverTimestamp(),
        });
        transaction.update(currentUserRef, {
          'followingCount': FieldValue.increment(1),
        });
        transaction.update(targetUserRef, {
          'followerCount': FieldValue.increment(1),
        });
      }
    });
  }

  // --- Post Methods ---
  Future<List<QueryDocumentSnapshot>> getPostsPaginated({
    int limit = 5,
    DocumentSnapshot? startAfter,
    String? authorHandle,
  }) async {
    print(
      "Querying posts. Author: $authorHandle, Community: ${currentCommunity.value}",
    );
    Query query = _firestore.collection('posts');

    if (authorHandle != null) {
      // Profile View: Fetch ALL posts by this user, regardless of community
      query = query.where('authorHandle', isEqualTo: authorHandle);
    } else {
      // Feed View: Fetch posts for the current community
      query = query.where('communityId', isEqualTo: currentCommunity.value);
    }

    // Feed View: Order by timestamp
    query = query.orderBy('timestamp', descending: true);

    query = query.limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final docs = (await query.get()).docs;

    return docs;
  }

  Future<void> addPost(
    String title,
    String? description,
    String authorHandle,
    String authorPhotoUrl, {
    String? ngoHandle,
    String? companyHandle,
    String? locationState,
    String? locationDistrict,
  }) async {
    final timestamp = DateTime.now();
    final score = 1;
    final hotness = _calculateHotness(score, timestamp);
    final postData = {
      'communityId': currentCommunity.value,
      'authorHandle': authorHandle,
      'authorPhotoUrl': authorPhotoUrl,
      'ngoHandle': ngoHandle ?? '',
      'companyHandle': companyHandle ?? '',
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'score': score,
      'hotness': hotness,
      'commentCount': 0,
      'upvoters': [authorHandle],
      'downvoters': [],
    };

    if (locationState != null) postData['locationState'] = locationState;
    if (locationDistrict != null)
      postData['locationDistrict'] = locationDistrict;

    await _firestore.collection('posts').add(postData);
  }

  Future<void> updatePostVote(
    String postId,
    String userId,
    VoteState currentVote,
    bool isUpvoteButton,
  ) async {
    final postRef = _firestore.collection('posts').doc(postId);
    return _runVoteTransaction(postRef, userId, currentVote, isUpvoteButton);
  }

  // --- Moderator Methods ---
  Future<void> deletePost(String postId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    await postRef.delete();
  }

  Future<void> editPost(String postId, String newText) async {
    final postRef = _firestore.collection('posts').doc(postId);
    await postRef.update({'text': newText});
  }

  // --- Comment Methods ---
  Future<void> addComment({
    required String postId,
    required String text,
    required String authorHandle,
    required String authorPhotoUrl,
  }) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc();
    final timestamp = DateTime.now();
    final score = 0;
    final hotness = _calculateHotness(score, timestamp);

    return _firestore.runTransaction((transaction) async {
      transaction.set(commentRef, {
        'authorHandle': authorHandle,
        'authorPhotoUrl': authorPhotoUrl,
        'text': text,
        'timestamp': Timestamp.fromDate(timestamp),
        'score': score,
        'hotness': hotness,
        'upvoters': [],
        'downvoters': [],
      });

      transaction.update(postRef, {'commentCount': FieldValue.increment(1)});
    });
  }

  Future<List<QueryDocumentSnapshot>> getComments({
    required String postId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('hotness', descending: true)
        .limit(limit);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    return (await query.get()).docs;
  }

  Future<void> updateCommentVote(
    String postId,
    String commentId,
    String userId,
    VoteState currentVote,
    bool isUpvoteButton,
  ) async {
    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);
    return _runVoteTransaction(commentRef, userId, currentVote, isUpvoteButton);
  }

  // --- Mapping Helpers ---
  Post mapSnapshotToPost(DocumentSnapshot doc, String currentUserId) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final upvoters = (data['upvoters'] is List)
        ? List<String>.from(data['upvoters'].whereType<String>())
        : <String>[];
    final downvoters = (data['downvoters'] is List)
        ? List<String>.from(data['downvoters'].whereType<String>())
        : <String>[];
    VoteState myVote = upvoters.contains(currentUserId)
        ? VoteState.up
        : (downvoters.contains(currentUserId)
              ? VoteState.down
              : VoteState.none);
    DateTime timestamp;
    if (data['timestamp'] is Timestamp) {
      timestamp = (data['timestamp'] as Timestamp).toDate();
    } else {
      timestamp = DateTime.now();
    }

    return Post(
      id: doc.id,
      authorHandle: data['authorHandle'] ?? 'u/unknown',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      title: data['title'] ?? data['text'] ?? '',
      description: data['description'],
      timestamp: timestamp,
      score: data['score'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      myVote: myVote,
      ngoHandle:
          (data['ngoHandle'] != null && data['ngoHandle'].toString().isNotEmpty)
          ? data['ngoHandle']
          : null,
      companyHandle:
          (data['companyHandle'] != null && data['companyHandle'].toString().isNotEmpty)
          ? data['companyHandle']
          : null,
      isVerified: data['isVerified'] ?? false,
      communityHandle: data['communityId'] ?? currentCommunity.value,
      locationState: data['locationState'],
      locationDistrict: data['locationDistrict'],
    );
  }

  Comment mapSnapshotToComment(
    DocumentSnapshot doc,
    String currentUserId, {
    int depth = 0,
  }) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final upvoters = (data['upvoters'] is List)
        ? List<String>.from(data['upvoters'].whereType<String>())
        : <String>[];
    final downvoters = (data['downvoters'] is List)
        ? List<String>.from(data['downvoters'].whereType<String>())
        : <String>[];
    VoteState myVote = upvoters.contains(currentUserId)
        ? VoteState.up
        : (downvoters.contains(currentUserId)
              ? VoteState.down
              : VoteState.none);
    DateTime timestamp;
    if (data['timestamp'] is Timestamp) {
      timestamp = (data['timestamp'] as Timestamp).toDate();
    } else {
      timestamp = DateTime.now();
    }

    return Comment(
      id: doc.id,
      parentId: data['parentId'],
      authorHandle: data['authorHandle'] ?? 'u/unknown',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      text: data['text'] ?? '',
      timestamp: timestamp,
      score: data['score'] ?? 0,
      replyCount: data['replyCount'] ?? 0,
      myVote: myVote,
    );
  }

  Future<List<Comment>> getUserComments(
    String authorHandle,
    String currentUserId,
  ) async {
    try {
      print("Querying comments for user: $authorHandle");

      // Attempt Collection Group Query (requires index)
      try {
        final query = _firestore
            .collectionGroup('comments')
            .where('authorHandle', isEqualTo: authorHandle)
        // .orderBy('timestamp', descending: true) // Commented out to reduce index requirements
        ;

        final docs = (await query.get()).docs;
        final comments = docs
            .map((doc) => mapSnapshotToComment(doc, currentUserId))
            .toList();
        comments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return comments;
      } catch (e) {
        print("CollectionGroup query failed (likely missing index): $e");
        throw e; // Trigger fallback
      }
    } catch (e) {
      print("Falling back to manual iteration for comments...");

      // Fallback: Iterate recent posts in CURRENT community to find comments.
      // This is inefficient (N+1) but works without indexes for MVP.
      List<Comment> allComments = [];
      try {
        // 1. Get recent posts (e.g., last 20)
        final postsSnapshot = await _firestore
            .collection('posts')
            .where('communityId', isEqualTo: currentCommunity.value)
            .orderBy('timestamp', descending: true)
            .limit(20) // Limit to avoid excessive reads
            .get();

        // 2. For each post, check for comments by this user
        List<Future<QuerySnapshot>> futures = [];
        for (var postDoc in postsSnapshot.docs) {
          futures.add(
            postDoc.reference
                .collection('comments')
                .where('authorHandle', isEqualTo: authorHandle)
                .get(),
          );
        }

        final results = await Future.wait(futures);

        for (var snap in results) {
          allComments.addAll(
            snap.docs.map((doc) => mapSnapshotToComment(doc, currentUserId)),
          );
        }

        // 3. Sort client-side
        allComments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (innerError) {
        print("Manual comment iteration failed: $innerError");
      }

      return allComments;
    }
  }

  Future<void> sendAccountChangeRequest({
    required String email,
    required String contactNumber,
    required String currentType,
    required String requestedType,
  }) async {
    await _firestore.collection('account_change_requests').add({
      'email': email,
      'contactNumber': contactNumber,
      'currentType': currentType,
      'requestedType': requestedType,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending', // pending, approved, rejected
    });
  }

  Future<void> sendCommunityRequest({
    required String name,
    required String email,
    required String description,
  }) async {
    await _firestore.collection('community_requests').add({
      'name': name,
      'email': email,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<void> sendIdeaSuggestion({
    required String email,
    required String suggestion,
  }) async {
    await _firestore.collection('idea_suggestions').add({
      'email': email,
      'suggestion': suggestion,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'new',
    });
  }

  // --- Impact Stand Methods ---

  Future<void> addImpactStand(
    String name,
    String community,
    String subHeading,
    String description,
    String type,
    List<Map<String, String>> whoShouldAct,
    List<String> photoUrls,
    String creatorId,
    String creatorEmail,
    String creatorName,
    bool isPetition,
  ) async {
    final standId = _generateStandId('IM');
    await _firestore.collection('impact_stands').add({
      'standId': standId,
      'name': name,
      'subHeading': subHeading,
      'description': description,
      'type': type,
      'whoShouldAct': whoShouldAct,
      'community': community,
      'photoUrls': photoUrls,
      'creatorId': creatorId,
      'creatorEmail': creatorEmail,
      'creatorName': creatorName,
      'standCount': 1, // Creator counts as one
      'takers': [creatorId], // Auto-add creator as taker
      'timestamp': FieldValue.serverTimestamp(),
      'isPetition': isPetition,
    });
  }

  Future<void> updateImpactStand({
    required String id,
    required String name,
    required String community,
    required String subHeading,
    required String description,
    required String type,
    required List<Map<String, String>> whoShouldAct,
    required List<String> photoUrls,
    required bool isPetition,
  }) async {
    await _firestore.collection('impact_stands').doc(id).update({
      'name': name,
      'subHeading': subHeading,
      'description': description,
      'type': type,
      'whoShouldAct': whoShouldAct,
      'community': community,
      'photoUrls': photoUrls,
      'isPetition': isPetition,
    });
  }

  Future<List<Map<String, dynamic>>> getImpactStands(
    String community,
    List<String> takenStandIds, // Pass the list of taken IDs
  ) async {
    try {
      final snapshot = await _firestore
          .collection('impact_stands')
          .get();

      final List<Map<String, dynamic>> results = snapshot.docs
          .where((doc) => (doc.data()['isVictory'] ?? false) != true)
          .map((doc) {
        final data = doc.data();
        final takers = List<String>.from(data['takers'] ?? []);
        final count = data['standCount'] ?? takers.length;

        return {
          'id': doc.id,
          'standId': data['standId'] ?? '',
          'name': data['name'] ?? 'Untitled Stand',
          'subHeading': data['subHeading'] ?? '',
          'description': data['description'] ?? '',
          'type': data['type'] ?? 'Other',
          'whoShouldAct': data['whoShouldAct'] ?? [],
          'community': data['community'] ?? community,
          'photoUrls': () {
            if (data['photoUrls'] is List) {
              final parsed = List<String>.from(
                (data['photoUrls'] as List).whereType<String>().where(
                  (url) => url.trim().isNotEmpty,
                ),
              );
              if (parsed.isNotEmpty) return parsed;
            }
            if (data['photoUrl'] != null &&
                data['photoUrl'].toString().trim().isNotEmpty) {
              return [data['photoUrl'].toString()];
            }
            return <String>[];
          }(),
          'creatorId': data['creatorId'] ?? '',
          'creatorEmail': data['creatorEmail'] ?? '',
          'creatorName': data['creatorName'] ?? 'Anonymous',
          'standCount': count,
          'commentCount': data['commentCount'] ?? 0,
          'hasTakenStand': takenStandIds.contains(doc.id),
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
          'status': data['status'] ?? 'active',
          'isPetition': data['isPetition'] ?? false,
        };
      }).toList();

      // Social sorting: Newest first
      results.sort((a, b) {
        final DateTime tA = a['timestamp'] ?? DateTime(2000);
        final DateTime tB = b['timestamp'] ?? DateTime(2000);
        return tB.compareTo(tA);
      });

      return results;
    } catch (e) {
      print("Error in getImpactStands: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserImpactStands(String userId) async {
    try {
      if (userId.isEmpty) {
        print("DEBUG: UserID is empty, returning empty list");
        return [];
      }

      final creatorSnapshot = await _firestore
          .collection('impact_stands')
          .where('creatorId', isEqualTo: userId)
          .get();
      print("DEBUG: Creator query found ${creatorSnapshot.docs.length} docs");

      final List<Map<String, dynamic>> resultList = [];
      for (var doc in creatorSnapshot.docs) {
        if ((doc.data()['isVictory'] ?? false) == true) continue;
        try {
          final data = doc.data();
          final takers = List<String>.from(data['takers'] ?? []);

          resultList.add({
            'id': doc.id,
            'standId': data['standId'] ?? '',
            'name': data['name'] ?? 'Untitled Stand',
            'subHeading': data['subHeading'] ?? '',
            'description': data['description'] ?? '',
            'type': data['type'] ?? 'Other',
            'whoShouldAct': data['whoShouldAct'] ?? [],
            'community': data['community'] ?? 'India',
            'photoUrls': () {
              if (data['photoUrls'] is List) {
                final parsed = List<String>.from(
                  (data['photoUrls'] as List).whereType<String>().where(
                    (url) => url.trim().isNotEmpty,
                  ),
                );
                if (parsed.isNotEmpty) return parsed;
              }
              if (data['photoUrl'] != null &&
                  data['photoUrl'].toString().trim().isNotEmpty) {
                return [data['photoUrl'].toString()];
              }
              return <String>[];
            }(),
            'creatorId': data['creatorId'] ?? '',
            'creatorEmail': data['creatorEmail'] ?? '',
            'creatorName': data['creatorName'] ?? 'Anonymous',
            'standCount': data['standCount'] ?? takers.length,
            'commentCount': data['commentCount'] ?? 0,
            'hasTakenStand': takers.contains(userId),
            'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
            'status': data['status'] ?? 'active',
            'isPetition': data['isPetition'] ?? false,
          });
        } catch (itemErr) {
          print("DEBUG: Failed to map stand ${doc.id}: $itemErr");
        }
      }

      resultList.sort((a, b) {
        final DateTime tA = a['timestamp'] ?? DateTime(2000);
        final DateTime tB = b['timestamp'] ?? DateTime(2000);
        return tB.compareTo(tA);
      });

      return resultList;
    } catch (e) {
      print("Error in getUserImpactStands: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getImpactStandById(String id) async {
    try {
      final doc = await _firestore.collection('impact_stands').doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      final takers = List<String>.from(data['takers'] ?? []);
      
      return {
        'id': doc.id,
        'standId': data['standId'] ?? '',
        'name': data['name'] ?? 'Untitled Stand',
        'subHeading': data['subHeading'] ?? '',
        'description': data['description'] ?? '',
        'type': data['type'] ?? 'Other',
        'whoShouldAct': data['whoShouldAct'] ?? [],
        'community': data['community'] ?? 'India',
        'photoUrls': () {
          if (data['photoUrls'] is List) {
            final parsed = List<String>.from(
              (data['photoUrls'] as List).whereType<String>().where(
                (url) => url.trim().isNotEmpty,
              ),
            );
            if (parsed.isNotEmpty) return parsed;
          }
          if (data['photoUrl'] != null &&
              data['photoUrl'].toString().trim().isNotEmpty) {
            return [data['photoUrl'].toString()];
          }
          return <String>[];
        }(),
        'creatorId': data['creatorId'] ?? '',
        'creatorEmail': data['creatorEmail'] ?? '',
        'creatorName': data['creatorName'] ?? 'Anonymous',
        'standCount': data['standCount'] ?? takers.length,
        'commentCount': data['commentCount'] ?? 0,
        'hasTakenStand': FirebaseAuth.instance.currentUser?.uid != null &&
            takers.contains(FirebaseAuth.instance.currentUser!.uid),
        'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
        'status': data['status'] ?? 'active',
        'isPetition': data['isPetition'] ?? false,
      };
    } catch (e) {
      print("Error in getImpactStandById: $e");
      return null;
    }
  }

  Future<void> toggleImpactStand(
    String standId,
    String userId,
    bool isTakingStand, {
    String? email,
    String? name,
    String? state,
    String? district,
    String? place,
  }) async {
    final standRef = _firestore.collection('impact_stands').doc(standId);
    final userRef = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        final standSnapshot = await transaction.get(standRef);
        if (!standSnapshot.exists) {
          throw Exception("Stand does not exist!");
        }
        final userSnapshot = await transaction.get(userRef);

        final standData = standSnapshot.data() ?? {};
        final userData = userSnapshot.exists ? (userSnapshot.data() ?? {}) : {};

        final standTakers = List<String>.from(standData['takers'] ?? []);
        final userStands = List<String>.from(userData['takenStandIds'] ?? []);

        final standHasUser = standTakers.contains(userId);
        final userHasStand = userStands.contains(standId);

        if (isTakingStand) {
          if (!standHasUser || !userHasStand) {
            final Map<String, dynamic> userUpdates = {
              'takenStandIds': FieldValue.arrayUnion([standId]),
            };
            if (!userHasStand) {
              userUpdates['dharma'] = FieldValue.increment(5);
            }
            transaction.update(userRef, userUpdates);

            final Map<String, dynamic> standUpdates = {
              'takers': FieldValue.arrayUnion([userId]),
              'takers_details.$userId': {
                'userId': userId,
                'name': name ?? '',
                'state': state ?? '',
                'district': district ?? '',
                'place': place ?? '',
                'signedAt': FieldValue.serverTimestamp(),
              }
            };
            if (!standHasUser) {
              standUpdates['standCount'] = FieldValue.increment(1);
            }
            transaction.update(standRef, standUpdates);
          } else {
            transaction.update(standRef, {
              'takers_details.$userId': {
                'userId': userId,
                'name': name ?? '',
                'state': state ?? '',
                'district': district ?? '',
                'place': place ?? '',
                'signedAt': FieldValue.serverTimestamp(),
              }
            });
          }
        } else {
          if (standHasUser || userHasStand) {
            final Map<String, dynamic> userUpdates = {
              'takenStandIds': FieldValue.arrayRemove([standId]),
            };
            if (userHasStand) {
              userUpdates['dharma'] = FieldValue.increment(-5);
            }
            transaction.update(userRef, userUpdates);

            final Map<String, dynamic> standUpdates = {
              'takers': FieldValue.arrayRemove([userId]),
              'takers_details.$userId': FieldValue.delete(),
            };
            if (standHasUser) {
              standUpdates['standCount'] = FieldValue.increment(-1);
            }
            transaction.update(standRef, standUpdates);
          }
        }
      });
    } catch (e) {
      print("Transaction failed: $e");
      throw e;
    }
  }

  Future<void> toggleCampaign(
    String campaignId,
    String userId,
    bool isTakingStand, {
    String? email,
    String? name,
    String? state,
    String? district,
    String? place,
  }) async {
    final campaignRef = _firestore.collection('campaigns').doc(campaignId);
    final userRef = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        final campaignSnapshot = await transaction.get(campaignRef);
        if (!campaignSnapshot.exists) {
          throw Exception("Campaign does not exist!");
        }
        final userSnapshot = await transaction.get(userRef);

        final campaignData = campaignSnapshot.data() ?? {};
        final userData = userSnapshot.exists ? (userSnapshot.data() ?? {}) : {};

        final campaignTakers = List<String>.from(campaignData['takers'] ?? []);
        final userStands = List<String>.from(userData['takenStandIds'] ?? []);

        final campaignHasUser = campaignTakers.contains(userId);
        final userHasCampaign = userStands.contains(campaignId);

        if (isTakingStand) {
          if (!campaignHasUser || !userHasCampaign) {
            final Map<String, dynamic> userUpdates = {
              'takenStandIds': FieldValue.arrayUnion([campaignId]),
            };
            if (!userHasCampaign) {
              userUpdates['dharma'] = FieldValue.increment(5);
            }
            transaction.update(userRef, userUpdates);

            final Map<String, dynamic> campaignUpdates = {
              'takers': FieldValue.arrayUnion([userId]),
              'takers_details.$userId': {
                'userId': userId,
                'name': name ?? '',
                'state': state ?? '',
                'district': district ?? '',
                'place': place ?? '',
                'signedAt': FieldValue.serverTimestamp(),
              }
            };
            if (!campaignHasUser) {
              campaignUpdates['standCount'] = FieldValue.increment(1);
            }
            transaction.update(campaignRef, campaignUpdates);
          } else {
            transaction.update(campaignRef, {
              'takers_details.$userId': {
                'userId': userId,
                'name': name ?? '',
                'state': state ?? '',
                'district': district ?? '',
                'place': place ?? '',
                'signedAt': FieldValue.serverTimestamp(),
              }
            });
          }
        } else {
          if (campaignHasUser || userHasCampaign) {
            final Map<String, dynamic> userUpdates = {
              'takenStandIds': FieldValue.arrayRemove([campaignId]),
            };
            if (userHasCampaign) {
              userUpdates['dharma'] = FieldValue.increment(-5);
            }
            transaction.update(userRef, userUpdates);

            final Map<String, dynamic> campaignUpdates = {
              'takers': FieldValue.arrayRemove([userId]),
              'takers_details.$userId': FieldValue.delete(),
            };
            if (campaignHasUser) {
              campaignUpdates['standCount'] = FieldValue.increment(-1);
            }
            transaction.update(campaignRef, campaignUpdates);
          }
        }
      });
    } catch (e) {
      print("Transaction failed: $e");
      throw e;
    }
  }

  // --- Impact Stand Comment Methods ---

  Future<void> addImpactStandComment({
    required String standId,
    required String text,
    required String authorHandle,
    required String authorPhotoUrl,
    String? parentId,
    int depth = 0,
  }) async {
    final standRef = _firestore.collection('impact_stands').doc(standId);
    final commentRef = standRef.collection('comments').doc();
    final timestamp = DateTime.now();
    final score = 0;
    final hotness = _calculateHotness(score, timestamp);

    return _firestore.runTransaction((transaction) async {
      transaction.set(commentRef, {
        'parentId': parentId,
        'depth': depth,
        'replyCount': 0,
        'authorHandle': authorHandle,
        'authorPhotoUrl': authorPhotoUrl,
        'text': text,
        'timestamp': Timestamp.fromDate(timestamp),
        'score': score,
        'hotness': hotness,
        'upvoters': [],
        'downvoters': [],
      });

      if (parentId != null) {
        final parentRef = standRef.collection('comments').doc(parentId);
        transaction.update(parentRef, {'replyCount': FieldValue.increment(1)});
      }

      transaction.update(standRef, {'commentCount': FieldValue.increment(1)});
    });
  }

  Future<List<QueryDocumentSnapshot>> getImpactStandComments({
    required String standId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _firestore
        .collection('impact_stands')
        .doc(standId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .limit(limit);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    return (await query.get()).docs;
  }

  Future<void> updateImpactStandCommentVote(
    String standId,
    String commentId,
    String userId,
    VoteState currentVote,
    bool isUpvoteButton,
  ) async {
    final commentRef = _firestore
        .collection('impact_stands')
        .doc(standId)
        .collection('comments')
        .doc(commentId);
    return _runVoteTransaction(commentRef, userId, currentVote, isUpvoteButton);
  }

  // --- Campaign Methods ---

  Future<void> addCampaign(
    String name,
    String community,
    String subHeading,
    String description,
    String type,
    List<dynamic> whoShouldAct,
    List<String> photoUrls,
    String creatorId,
    String creatorEmail,
    String creatorName,
  ) async {
    final standId = _generateStandId('CP');
    await _firestore.collection('campaigns').add({
      'standId': standId,
      'name': name,
      'subHeading': subHeading,
      'description': description,
      'type': type,
      'whoShouldAct': whoShouldAct,
      'community': community,
      'photoUrls': photoUrls,
      'creatorId': creatorId,
      'creatorEmail': creatorEmail,
      'creatorName': creatorName,
      'standCount': 1, 
      'takers': [creatorId], 
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCampaign({
    required String id,
    required String name,
    required String community,
    required String subHeading,
    required String description,
    required String type,
    required List<dynamic> whoShouldAct,
    required List<String> photoUrls,
  }) async {
    await _firestore.collection('campaigns').doc(id).update({
      'name': name,
      'subHeading': subHeading,
      'description': description,
      'type': type,
      'whoShouldAct': whoShouldAct,
      'community': community,
      'photoUrls': photoUrls,
    });
  }

  Future<List<Map<String, dynamic>>> getCampaigns(
    String community,
    List<String> takenStandIds, 
  ) async {
    try {
      final snapshot = await _firestore
          .collection('campaigns')
          .get();

      final List<Map<String, dynamic>> results = snapshot.docs
          .where((doc) => (doc.data()['isVictory'] ?? false) != true)
          .map((doc) {
        final data = doc.data();
        final takers = List<String>.from(data['takers'] ?? []);
        final count = data['standCount'] ?? takers.length;

        return {
          'id': doc.id,
          'standId': data['standId'] ?? '',
          'name': data['name'] ?? 'Untitled Campaign',
          'subHeading': data['subHeading'] ?? '',
          'description': data['description'] ?? '',
          'type': data['type'] ?? 'Other',
          'whoShouldAct': data['whoShouldAct'] ?? [],
          'community': data['community'] ?? community,
          'photoUrls': () {
            if (data['photoUrls'] is List) {
              final parsed = List<String>.from(
                (data['photoUrls'] as List).whereType<String>().where(
                  (url) => url.trim().isNotEmpty,
                ),
              );
              if (parsed.isNotEmpty) return parsed;
            }
            if (data['photoUrl'] != null &&
                data['photoUrl'].toString().trim().isNotEmpty) {
              return [data['photoUrl'].toString()];
            }
            return <String>[];
          }(),
          'creatorId': data['creatorId'] ?? '',
          'creatorEmail': data['creatorEmail'] ?? '',
          'creatorName': data['creatorName'] ?? 'Anonymous',
          'standCount': count,
          'commentCount': data['commentCount'] ?? 0,
          'hasTakenStand': takenStandIds.contains(doc.id),
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
          'status': data['status'] ?? 'active',
        };
      }).toList();

      results.sort((a, b) {
        final DateTime tA = a['timestamp'] ?? DateTime(2000);
        final DateTime tB = b['timestamp'] ?? DateTime(2000);
        return tB.compareTo(tA);
      });

      return results;
    } catch (e) {
      print("Error in getCampaigns: $e");
      return [];
    }
  }

  // --- Cross-community feed methods (for home screen) ---

  Future<List<Map<String, dynamic>>> getImpactStandsForCommunities(
    List<String> communityIds,
    List<String> takenStandIds,
  ) async {
    if (communityIds.isEmpty) return [];
    try {
      print("DEBUG: Fetching impact stands for: $communityIds");
      // Firestore whereIn supports up to 30 values
      final snapshot = await _firestore
          .collection('impact_stands')
          .where('community', whereIn: communityIds.take(30).toList())
          .get();
      
      print("DEBUG: Found ${snapshot.docs.length} stands across communities");

      final List<Map<String, dynamic>> results = snapshot.docs
          .where((doc) => (doc.data()['isVictory'] ?? false) != true)
          .map((doc) {
        final data = doc.data();
        final takers = List<String>.from(data['takers'] ?? []);
        final count = data['standCount'] ?? takers.length;

        return {
          'id': doc.id,
          'standId': data['standId'] ?? '',
          'name': data['name'] ?? 'Untitled Stand',
          'subHeading': data['subHeading'] ?? '',
          'description': data['description'] ?? '',
          'type': data['type'] ?? 'Other',
          'whoShouldAct': data['whoShouldAct'] ?? [],
          'community': data['community'] ?? '',
          'photoUrls': () {
            if (data['photoUrls'] is List) {
              final parsed = List<String>.from(
                (data['photoUrls'] as List).whereType<String>().where(
                  (url) => url.trim().isNotEmpty,
                ),
              );
              if (parsed.isNotEmpty) return parsed;
            }
            if (data['photoUrl'] != null &&
                data['photoUrl'].toString().trim().isNotEmpty) {
              return [data['photoUrl'].toString()];
            }
            return <String>[];
          }(),
          'creatorId': data['creatorId'] ?? '',
          'creatorEmail': data['creatorEmail'] ?? '',
          'creatorName': data['creatorName'] ?? 'Anonymous',
          'standCount': count,
          'commentCount': data['commentCount'] ?? 0,
          'hasTakenStand': takenStandIds.contains(doc.id),
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
          'status': data['status'] ?? 'active',
          'isPetition': data['isPetition'] ?? false,
        };
      }).toList();

      results.sort((a, b) {
        final DateTime tA = a['timestamp'] ?? DateTime(2000);
        final DateTime tB = b['timestamp'] ?? DateTime(2000);
        return tB.compareTo(tA);
      });

      return results;
    } catch (e) {
      print('Error in getImpactStandsForCommunities: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCampaignsForCommunities(
    List<String> communityIds,
    List<String> takenStandIds,
  ) async {
    if (communityIds.isEmpty) return [];
    try {
      print("DEBUG: Fetching campaigns for: $communityIds");
      final snapshot = await _firestore
          .collection('campaigns')
          .where('community', whereIn: communityIds.take(30).toList())
          .get();
      
      print("DEBUG: Found ${snapshot.docs.length} campaigns across communities");
      for (var doc in snapshot.docs) {
        print("DEBUG: Campaign ID: ${doc.id}, Name: ${doc.get('name')}, Community: ${doc.get('community')}, Status: ${doc.data().containsKey('status') ? doc.get('status') : 'N/A'}");
      }

      final List<Map<String, dynamic>> results = snapshot.docs
          .where((doc) => (doc.data()['isVictory'] ?? false) != true)
          .map((doc) {
        final data = doc.data();
        final takers = List<String>.from(data['takers'] ?? []);
        final count = data['standCount'] ?? takers.length;

        return {
          'id': doc.id,
          'standId': data['standId'] ?? '',
          'name': data['name'] ?? 'Untitled Campaign',
          'subHeading': data['subHeading'] ?? '',
          'description': data['description'] ?? '',
          'type': data['type'] ?? 'Other',
          'whoShouldAct': data['whoShouldAct'] ?? [],
          'community': data['community'] ?? '',
          'photoUrls': () {
            if (data['photoUrls'] is List) {
              final parsed = List<String>.from(
                (data['photoUrls'] as List).whereType<String>().where(
                  (url) => url.trim().isNotEmpty,
                ),
              );
              if (parsed.isNotEmpty) return parsed;
            }
            if (data['photoUrl'] != null &&
                data['photoUrl'].toString().trim().isNotEmpty) {
              return [data['photoUrl'].toString()];
            }
            return <String>[];
          }(),
          'creatorId': data['creatorId'] ?? '',
          'creatorEmail': data['creatorEmail'] ?? '',
          'creatorName': data['creatorName'] ?? 'Anonymous',
          'standCount': count,
          'commentCount': data['commentCount'] ?? 0,
          'hasTakenStand': takenStandIds.contains(doc.id),
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
          'status': data['status'] ?? 'active',
        };
      }).toList();

      results.sort((a, b) {
        final DateTime tA = a['timestamp'] ?? DateTime(2000);
        final DateTime tB = b['timestamp'] ?? DateTime(2000);
        return tB.compareTo(tA);
      });

      return results;
    } catch (e) {
      print('Error in getCampaignsForCommunities: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserCampaigns(String userId) async {
    try {
      if (userId.isEmpty) return [];

      final creatorSnapshot = await _firestore
          .collection('campaigns')
          .where('creatorId', isEqualTo: userId)
          .get();

      final List<Map<String, dynamic>> resultList = [];
      for (var doc in creatorSnapshot.docs) {
        if ((doc.data()['isVictory'] ?? false) == true) continue;
        try {
          final data = doc.data();
          final takers = List<String>.from(data['takers'] ?? []);

          resultList.add({
            'id': doc.id,
            'standId': data['standId'] ?? '',
            'name': data['name'] ?? 'Untitled Campaign',
            'subHeading': data['subHeading'] ?? '',
            'description': data['description'] ?? '',
            'type': data['type'] ?? 'Other',
            'whoShouldAct': data['whoShouldAct'] ?? [],
            'community': data['community'] ?? 'India',
            'photoUrls': () {
              if (data['photoUrls'] is List) {
                final parsed = List<String>.from(
                  (data['photoUrls'] as List).whereType<String>().where(
                    (url) => url.trim().isNotEmpty,
                  ),
                );
                if (parsed.isNotEmpty) return parsed;
              }
              if (data['photoUrl'] != null &&
                  data['photoUrl'].toString().trim().isNotEmpty) {
                return [data['photoUrl'].toString()];
              }
              return <String>[];
            }(),
            'creatorId': data['creatorId'] ?? '',
            'creatorEmail': data['creatorEmail'] ?? '',
            'creatorName': data['creatorName'] ?? 'Anonymous',
            'standCount': data['standCount'] ?? takers.length,
            'commentCount': data['commentCount'] ?? 0,
            'hasTakenStand': takers.contains(userId),
            'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
            'status': data['status'] ?? 'active',
          });
        } catch (itemErr) {
          print("DEBUG: Failed to map campaign ${doc.id}: $itemErr");
        }
      }

      resultList.sort((a, b) {
        final DateTime tA = a['timestamp'] ?? DateTime(2000);
        final DateTime tB = b['timestamp'] ?? DateTime(2000);
        return tB.compareTo(tA);
      });

      return resultList;
    } catch (e) {
      print("Error in getUserCampaigns: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getLeaderboard({int limit = 20}) async {
    return (await _firestore
            .collection('users')
            .orderBy('dharma', descending: true)
            .limit(limit)
            .get())
        .docs;
  }

  // --- Reporting Methods ---
  Future<void> reportComment({
    required String reason,
    required String commentId,
    required String commentText,
    required String commentAuthorHandle,
    required String reportedByHandle,
    required String standId,
    required String standName,
  }) async {
    await _firestore.collection('reported_comments').add({
      'reason': reason,
      'commentId': commentId,
      'commentText': commentText,
      'commentAuthorHandle': commentAuthorHandle,
      'reportedByHandle': reportedByHandle,
      'standId': standId,
      'standName': standName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // --- Victory Stands Methods ---

  Future<Map<String, dynamic>?> getCampaignByStandId(String standId) async {
    final snapshot = await _firestore
        .collection('campaigns')
        .where('standId', isEqualTo: standId.trim())
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    final data = doc.data();
    return {
      'id': doc.id,
      ...data,
    };
  }

  Future<List<Map<String, dynamic>>> searchCompaniesByName(String query) async {
    final snapshot = await _firestore
        .collection('users')
        .where('profileType', isEqualTo: 'company')
        .get();
    
    final lowercaseQuery = query.toLowerCase().trim();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          return {
            'uid': doc.id,
            'companyName': data['companyName'] ?? data['name'] ?? '',
            'companyLogo': data['companyLogo'] ?? data['photoUrl'] ?? '',
            'companyIndustry': data['companyIndustry'] ?? '',
          };
        })
        .where((c) => c['companyName'].toString().toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  Future<void> convertCampaignToVictory({
    required String campaignId,
    required String campaignStandId,
    required String companyId,
    required String companyName,
    required String victoryTitle,
    required String victoryDescription,
    required List<String> beforeImages,
    required List<String> afterImages,
    required Map<String, dynamic> campaignData,
  }) async {
    final batch = _firestore.batch();

    // 1. Update the original campaign
    final campaignRef = _firestore.collection('campaigns').doc(campaignId);
    batch.update(campaignRef, {
      'isVictory': true,
      'status': 'victory',
    });

    // 2. Create the victory stand document
    final victoryRef = _firestore.collection('victory_stands').doc();
    batch.set(victoryRef, {
      'campaignStandId': campaignStandId,
      'campaignId': campaignId,
      'companyId': companyId,
      'companyName': companyName,
      'victoryTitle': victoryTitle,
      'victoryDescription': victoryDescription,
      'beforeImages': beforeImages,
      'afterImages': afterImages,
      'createdAt': FieldValue.serverTimestamp(),

      // Transferred campaign fields
      'campaignName': campaignData['name'] ?? '',
      'campaignSubHeading': campaignData['subHeading'] ?? '',
      'campaignDescription': campaignData['description'] ?? '',
      'campaignType': campaignData['type'] ?? 'Other',
      'campaignWhoShouldAct': campaignData['whoShouldAct'] ?? [],
      'campaignCommunity': campaignData['community'] ?? 'india',
      'campaignPhotoUrls': campaignData['photoUrls'] ?? [],
      'campaignStandCount': campaignData['standCount'] ?? 0,
      'campaignCreatorId': campaignData['creatorId'] ?? '',
      'campaignCreatorName': campaignData['creatorName'] ?? 'Anonymous',
      'campaignCreatorEmail': campaignData['creatorEmail'] ?? '',
    });

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getVictoryStands() async {
    try {
      print('=== getVictoryStands: querying victory_stands collection ===');
      QuerySnapshot snapshot;
      try {
        snapshot = await _firestore
            .collection('victory_stands')
            .orderBy('createdAt', descending: true)
            .get();
      } catch (orderByErr) {
        // Index may not exist yet — fall back to unordered fetch
        print('=== getVictoryStands: orderBy failed ($orderByErr), retrying without orderBy ===');
        snapshot = await _firestore
            .collection('victory_stands')
            .get();
      }

      print('=== getVictoryStands: snapshot has ${snapshot.docs.length} docs ===');

      final List<Map<String, dynamic>> results = [];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print('  Processing doc id=${doc.id}, title="${data['victoryTitle']}"');

          // Safe cast lists
          final List<String> beforeImages = [];
          if (data['beforeImages'] is List) {
            beforeImages.addAll(List<String>.from((data['beforeImages'] as List).whereType<String>()));
          }

          final List<String> afterImages = [];
          if (data['afterImages'] is List) {
            afterImages.addAll(List<String>.from((data['afterImages'] as List).whereType<String>()));
          }

          final List<String> campaignPhotoUrls = [];
          if (data['campaignPhotoUrls'] is List) {
            campaignPhotoUrls.addAll(List<String>.from((data['campaignPhotoUrls'] as List).whereType<String>()));
          }

          DateTime createdAt = DateTime.now();
          if (data['createdAt'] is Timestamp) {
            createdAt = (data['createdAt'] as Timestamp).toDate();
          } else if (data['createdAt'] is String) {
            createdAt = DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now();
          }

          results.add({
            'id': doc.id,
            'campaignStandId': data['campaignStandId'] ?? '',
            'campaignId': data['campaignId'] ?? '',
            'companyId': data['companyId'] ?? '',
            'companyName': data['companyName'] ?? '',
            'victoryTitle': data['victoryTitle'] ?? '',
            'victoryDescription': data['victoryDescription'] ?? '',
            'victoryNote': data['victoryNote'] ?? '',
            'victoryWhoActed': data['victoryWhoActed'] ?? [],
            'beforeImages': beforeImages,
            'afterImages': afterImages,
            'createdAt': createdAt,
            'isImpactStand': data['isImpactStand'] ?? false,

            // Mapped copied campaign details
            'campaignName': data['campaignName'] ?? '',
            'campaignSubHeading': data['campaignSubHeading'] ?? '',
            'campaignDescription': data['campaignDescription'] ?? '',
            'campaignType': data['campaignType'] ?? 'Other',
            'campaignWhoShouldAct': data['campaignWhoShouldAct'] ?? [],
            'campaignCommunity': data['campaignCommunity'] ?? 'india',
            'campaignPhotoUrls': campaignPhotoUrls,
            'campaignStandCount': data['campaignStandCount'] ?? 0,
            'campaignCreatorId': data['campaignCreatorId'] ?? '',
            'campaignCreatorName': data['campaignCreatorName'] ?? 'Anonymous',
            'campaignCreatorEmail': data['campaignCreatorEmail'] ?? '',
          });
        } catch (itemErr, stack) {
          print("ERROR mapping victory stand ${doc.id}: $itemErr\n$stack");
        }
      }
      return results;
    } catch (e) {
      print("Error in getVictoryStands: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getImpactStandByStandId(String standId) async {
    final snapshot = await _firestore
        .collection('impact_stands')
        .where('standId', isEqualTo: standId.trim())
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    final data = doc.data();
    return {
      'id': doc.id,
      ...data,
    };
  }

  Future<void> convertImpactStandToVictory({
    required String impactStandId,
    required String impactStandCode,
    required String companyId,
    required String companyName,
    required String victoryTitle,
    required String victorySubTitle,
    required String victoryDescription,
    required String victoryNote,
    required List<Map<String, String>> victoryWhoActed,
    required List<String> beforeImages,
    required List<String> afterImages,
    required Map<String, dynamic> impactStandData,
  }) async {
    final batch = _firestore.batch();

    // 1. Update the original impact stand
    final standRef = _firestore.collection('impact_stands').doc(impactStandId);
    batch.update(standRef, {
      'isVictory': true,
      'status': 'victory',
    });

    // 2. Create the victory stand document
    final victoryRef = _firestore.collection('victory_stands').doc();
    batch.set(victoryRef, {
      'campaignStandId': impactStandCode,
      'campaignId': impactStandId,
      'companyId': companyId,
      'companyName': companyName,
      'victoryTitle': victoryTitle,
      'victoryDescription': victoryDescription,
      'victoryNote': victoryNote,
      'victoryWhoActed': victoryWhoActed,
      'beforeImages': beforeImages,
      'afterImages': afterImages,
      'createdAt': FieldValue.serverTimestamp(),
      'isImpactStand': true,

      // Transferred impact stand fields (mapped to the campaign fields in schema to remain unified)
      'campaignName': victoryTitle,
      'campaignSubHeading': victorySubTitle,
      'campaignDescription': victoryDescription,
      'campaignType': impactStandData['type'] ?? 'Other',
      'campaignWhoShouldAct': impactStandData['whoShouldAct'] ?? [],
      'campaignCommunity': impactStandData['community'] ?? 'india',
      'campaignPhotoUrls': impactStandData['photoUrls'] ?? [],
      'campaignStandCount': impactStandData['standCount'] ?? 0,
      'campaignCreatorId': impactStandData['creatorId'] ?? '',
      'campaignCreatorName': impactStandData['creatorName'] ?? 'Anonymous',
      'campaignCreatorEmail': impactStandData['creatorEmail'] ?? '',
    });

    await batch.commit();
  }
}
