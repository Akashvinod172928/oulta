import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/profile/view/user_profile_page.dart';
import 'package:oulta/features/presentation/social/comments/controller/comment_controller.dart';
import 'package:oulta/features/presentation/social/comments/widgets/comment_card.dart';
import 'package:oulta/features/presentation/social/widgets/post_card.dart';

class CommentScreen extends StatelessWidget {
  final Post post;

  const CommentScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CommentController controller = Get.put(
      CommentController(targetId: post.id, source: CommentSource.post),
      tag: post.id,
    );
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isFirstLoad.value && controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.comments.isEmpty) {
                return const Center(child: Text('No comments yet.'));
              }
              return ListView.builder(
                itemCount: controller.comments.length,
                itemBuilder: (context, index) {
                  final comment = controller.comments[index];
                  // --- Simplified CommentCard, nested features disabled ---
                  return CommentCard(
                    comment: comment,
                    onVote: (currentVote, isUpvote) => controller.voteOnComment(
                      comment.id,
                      currentVote,
                      isUpvote,
                    ),
                    onUsernameTap: () => Get.to(
                      () => UserProfilePage(username: comment.authorHandle),
                    ),
                  );
                },
              );
            }),
          ),
          _buildCommentInput(
            context,
            controller,
            textController,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(
    BuildContext context,
    CommentController controller,
    TextEditingController textController,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Colors.blueAccent),
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.addComment(textController.text);
                textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
