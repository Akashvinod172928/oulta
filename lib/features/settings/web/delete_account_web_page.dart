import 'package:flutter/material.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';

class DeleteAccountWebPage extends StatelessWidget {
  const DeleteAccountWebPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'OULTA – Account Deletion',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Set a max width for readability
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'We respect your privacy and give you full control over your data.',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                SizedBox(height: 24),
                _Heading(text: '🧭 How to Delete Your Account'),
                SizedBox(height: 12),
                _BodyText(
                  text: 'You can request deletion of your OULTA account and all associated data in two ways:',
                ),
                SizedBox(height: 12),
                _BulletPoint(
                  text: 'Open the OULTA app → go to Profile → Settings → Delete Account (if available), or',
                ),
                _BulletPoint(
                  text: 'Send an email to support@oulta.org with the subject “Delete My Account.” Please use the same Google account you use to sign in to OULTA.',
                ),
                SizedBox(height: 12),
                _BodyText(
                  text: 'After receiving your request, we’ll verify your identity and permanently delete your account within 7 business days.',
                ),
                SizedBox(height: 24),
                _Heading(text: '🗑️ What Will Be Deleted'),
                SizedBox(height: 12),
                _BulletPoint(text: 'Your OULTA account and sign-in information'),
                _BulletPoint(text: 'Profile data (name, email, Dharma Points, rank)'),
                _BulletPoint(text: 'Your posts, comments, and other activity data'),
                SizedBox(height: 24),
                _Heading(text: '💾 What May Be Retained'),
                SizedBox(height: 12),
                _BulletPoint(text: 'Limited anonymized analytics for app performance and security'),
                _BulletPoint(text: 'Temporary backup copies retained for up to 30 days, after which they are permanently erased'),
                SizedBox(height: 24),
                _Heading(text: '🔒 Need Help?'),
                SizedBox(height: 12),
                _BodyText(
                  text: 'If you face any issues or want confirmation after deletion, contact us at support@oulta.org',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widgets for styling to keep the build method clean
class _Heading extends StatelessWidget {
  final String text;
  const _Heading({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
