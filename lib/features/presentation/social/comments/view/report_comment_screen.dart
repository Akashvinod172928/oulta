import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/data/social/services/firebase_service.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';
import 'package:oulta/features/presentation/social/comments/widgets/comment_card.dart';

class ReportCommentScreen extends StatefulWidget {
  final Comment comment;
  final String standId;
  final String standName;

  const ReportCommentScreen({
    Key? key,
    required this.comment,
    required this.standId,
    required this.standName,
  }) : super(key: key);

  @override
  State<ReportCommentScreen> createState() => _ReportCommentScreenState();
}

class _ReportCommentScreenState extends State<ReportCommentScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final NameController _nameController = Get.find<NameController>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      Get.snackbar('Reason Required', 'Please explain why you are reporting this comment.');
      return;
    }

    if (_nameController.userName.value.isEmpty) {
      Get.snackbar('Error', 'You must be logged in to report content.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _firebaseService.reportComment(
        reason: reason,
        commentId: widget.comment.id,
        commentText: widget.comment.text,
        commentAuthorHandle: widget.comment.authorHandle,
        reportedByHandle: _nameController.userName.value,
        standId: widget.standId,
        standName: widget.standName,
      );

      // Close the report screen immediately
      Get.back(); 
      
      // Show confirmation on the previous screen
      Get.snackbar(
        'Report Submitted', 
        'Thank you for reporting. We will review it shortly.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit report: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Report Content', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Why are you reporting?',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.black,
                  letterSpacing: -0.8
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tell us what is wrong with this comment. We investigate every report to ensure our community stays safe and respectful.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              
              // Comment Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black12,
                          backgroundImage: widget.comment.authorPhotoUrl.isNotEmpty 
                            ? NetworkImage(widget.comment.authorPhotoUrl) 
                            : null,
                          child: widget.comment.authorPhotoUrl.isEmpty 
                            ? const Icon(Icons.person, size: 14, color: Colors.white) 
                            : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'u/${widget.comment.authorHandle}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.comment.text,
                      style: TextStyle(
                        color: Colors.grey.shade800, 
                        fontSize: 15, 
                        height: 1.4,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              const Text(
                'Reason for Report',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                maxLines: 6,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'e.g. Harassment, Hate speech, Spam...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF2F2F2))),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 24, 
                      width: 24, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                    )
                  : const Text(
                      'Confirm Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
