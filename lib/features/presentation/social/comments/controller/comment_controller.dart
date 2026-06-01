import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';
import 'package:oulta/features/presentation/social/comments/widgets/comment_card.dart';
import 'package:oulta/features/data/social/services/firebase_service.dart';
import 'package:oulta/features/presentation/social/widgets/post_card.dart'; // For VoteState

// --- Simplified Controller: Nested Comments Disabled ---
enum CommentSource { post, impactStand }

class CommentController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final NameController _nameController = Get.find<NameController>();
  final String targetId;
  final CommentSource source;

  // --- Observables ---
  final comments = <Comment>[].obs;
  final isLoading = false.obs;
  final isFirstLoad = true.obs;
  final isAddingComment = false.obs;

  // --- Pagination State ---
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  String get currentUserHandle => _nameController.userName.value;
  String get currentUserPhotoUrl => _nameController.userPhotoUrl.value;

  CommentController({required this.targetId, this.source = CommentSource.post});

  @override
  void onInit() {
    super.onInit();
    fetchComments();
  }

  Future<void> fetchComments({bool isLoadMore = false}) async {
    if (isLoading.isTrue || (isLoadMore && !_hasMore)) return;

    isLoading.value = true;

    try {
      final List<QueryDocumentSnapshot> snapshots;
      if (source == CommentSource.post) {
        snapshots = await _firebaseService.getComments(
          postId: targetId,
          startAfter: isLoadMore ? _lastDocument : null,
        );
      } else {
        snapshots = await _firebaseService.getImpactStandComments(
          standId: targetId,
          startAfter: isLoadMore ? _lastDocument : null,
        );
      }

      if (snapshots.isNotEmpty) {
        _lastDocument = snapshots.last;
        final newComments = snapshots
            .map(
              (doc) =>
                  _firebaseService.mapSnapshotToComment(doc, currentUserHandle),
            )
            .toList();

        if (isLoadMore) {
          comments.addAll(newComments);
        } else {
          comments.value = newComments;
        }
      } else if (!isLoadMore) {
        comments.clear();
      }

      _hasMore = snapshots.length >= 20;
    } catch (e) {
      print("Error fetching comments: $e");
    } finally {
      isLoading.value = false;
      if (isFirstLoad.isTrue) isFirstLoad.value = false;
    }
  }

  Future<bool> addComment(String text) async {
    if (text.trim().isEmpty) return false;
    if (_nameController.screenState.value != ScreenState.loggedIn) {
      Get.snackbar('Login Required', 'You must be signed in to comment.');
      return false;
    }

    isAddingComment.value = true;

    // Optimistic UI
    final tempId = "TEMP_${DateTime.now().millisecondsSinceEpoch}";
    final tempComment = Comment(
      id: tempId,
      parentId: null,
      authorHandle: currentUserHandle,
      authorPhotoUrl: currentUserPhotoUrl,
      text: text,
      timestamp: DateTime.now(),
      score: 0,
      myVote: VoteState.none,
    );
    
    // Insert at the top for optimistic UI
    comments.insert(0, tempComment);

    try {
      if (source == CommentSource.post) {
        await _firebaseService.addComment(
          postId: targetId,
          text: text,
          authorHandle: currentUserHandle,
          authorPhotoUrl: currentUserPhotoUrl,
        );
      } else {
        await _firebaseService.addImpactStandComment(
          standId: targetId,
          text: text,
          authorHandle: currentUserHandle,
          authorPhotoUrl: currentUserPhotoUrl,
        );
      }

      // Instead of full refresh, just update from server to get correct IDs/timestamps
      await fetchComments();
      return true;
    } catch (e) {
      comments.removeWhere((c) => c.id == tempId);
      Get.snackbar('Error', 'Failed to add comment: $e');
      return false;
    } finally {
      isAddingComment.value = false;
    }
  }

  // Reply methods removed.

  Future<void> voteOnComment(
    String commentId,
    VoteState currentVote,
    bool isUpvoteButton,
  ) async {
    final index = comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;

    final comment = comments[index];
    int newScore = comment.score;
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

    comments[index] = Comment(
      id: comment.id,
      parentId: comment.parentId,
      replyCount: comment.replyCount,
      authorHandle: comment.authorHandle,
      authorPhotoUrl: comment.authorPhotoUrl,
      text: comment.text,
      timestamp: comment.timestamp,
      score: newScore,
      myVote: newVoteState,
    );

    try {
      if (source == CommentSource.post) {
        await _firebaseService.updateCommentVote(
          targetId,
          commentId,
          currentUserHandle,
          currentVote,
          isUpvoteButton,
        );
      } else {
        await _firebaseService.updateImpactStandCommentVote(
          targetId,
          commentId,
          currentUserHandle,
          currentVote,
          isUpvoteButton,
        );
      }
    } catch (e) {
      comments[index] = comment; // Revert on error
      Get.snackbar('Error', 'Vote failed: $e');
    }
  }
}
