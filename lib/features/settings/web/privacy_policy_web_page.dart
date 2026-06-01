import 'package:flutter/material.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';

class PrivacyPolicyWebPage extends StatelessWidget {
  const PrivacyPolicyWebPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Privacy Policy',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Last updated: [Insert Date]',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black54),
                ),
                SizedBox(height: 16),
                _BodyText(
                  text: 'OULTA (“we,” “our,” or “us”) respects your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application OULTA and our website (oulta.org). By using OULTA, you agree to the terms described below.',
                ),
                SizedBox(height: 24),
                _Heading(text: '1. Information We Collect'),
                SizedBox(height: 12),
                _BodyText(text: 'We collect the following types of information to provide and improve our services:'),
                SizedBox(height: 12),
                _SubHeading(text: 'a. Personal Information'),
                _BulletPoint(text: 'Your name'),
                _BulletPoint(text: 'Your email address'),
                _BulletPoint(text: 'A unique user ID created by Firebase Authentication'),
                _BodyText(text: 'We do not collect passwords or payment information.'),
                 SizedBox(height: 12),
                _SubHeading(text: 'b. User-Generated Content'),
                _BulletPoint(text: 'Text posts, comments, and other content'),
                _BulletPoint(text: 'Upvotes, interactions, and profile information'),
                 _BodyText(text: 'This information is stored securely in Firebase Firestore.'),
                 SizedBox(height: 12),
                _SubHeading(text: 'c. Automatically Collected Data'),
                _BulletPoint(text: 'Device identifiers and app version (for analytics and security)'),
                _BulletPoint(text: 'Crash logs and diagnostics (via Firebase Crashlytics)'),
                _BodyText(text: 'All data in transit is encrypted (HTTPS/TLS).'),

                SizedBox(height: 24),
                _Heading(text: '2. How We Use Your Information'),
                 SizedBox(height: 12),
                _BodyText(text: 'We use collected information to:'),
                _BulletPoint(text: 'Authenticate and manage user accounts'),
                _BulletPoint(text: 'Display user profiles and posts'),
                _BulletPoint(text: 'Maintain app functionality and improve performance'),
                _BulletPoint(text: 'Communicate updates or respond to support requests'),
                _BulletPoint(text: 'Detect and prevent spam or abuse'),
                _BodyText(text: 'We do not sell or rent your data to third parties.'),

                SizedBox(height: 24),
                _Heading(text: '3. Data Sharing'),
                 SizedBox(height: 12),
                _BodyText(text: 'We do not share personal information with outside organizations except:'),
                 _BulletPoint(text: 'Firebase (Google LLC) – to provide authentication, storage, and analytics'),
                _BulletPoint(text: 'Legal or regulatory authorities – only if required by law'),
                _BodyText(text: 'All partners process data securely and under strict confidentiality.'),

                SizedBox(height: 24),
                _Heading(text: '4. Data Retention and Deletion'),
                 SizedBox(height: 12),
                 _BodyText(text: 'You may request deletion of your account at any time through the app or by emailing support@oulta.org.'),
                 _BodyText(text: 'Upon request, we permanently delete your account, profile data, posts, and interactions within 7 business days.'),
                _BodyText(text: 'Backups may be retained for up to 30 days for security and recovery purposes, after which they are automatically erased.'),
                 _BodyText(text: 'Some anonymized analytics data may remain for aggregate reporting.'),

                SizedBox(height: 24),
                _Heading(text: '5. Data Security'),
                 SizedBox(height: 12),
                _BodyText(text: 'Your information is protected using:'),
                _BulletPoint(text: 'Encrypted data transmission (HTTPS/TLS)'),
                _BulletPoint(text: 'Secure Firebase infrastructure and access controls'),
                _BulletPoint(text: 'Limited employee access on a need-to-know basis'),
                _BodyText(text: 'However, no online system is completely secure; we encourage users to protect their own accounts.'),

                SizedBox(height: 24),
                _Heading(text: '6. Children’s Privacy'),
                 SizedBox(height: 12),
                 _BodyText(text: 'OULTA is intended for users 16 years and older. We do not knowingly collect data from children. If we become aware of such data, we will delete it promptly.'),

                 SizedBox(height: 24),
                _Heading(text: '7. International Data Transfers'),
                 SizedBox(height: 12),
                _BodyText(text: 'Data may be stored and processed on servers located in multiple regions (via Google Firebase). By using OULTA, you consent to this transfer and processing.'),

                 SizedBox(height: 24),
                _Heading(text: '8. Contact Us'),
                 SizedBox(height: 12),
                _BodyText(text: 'If you have questions about this Privacy Policy or your data, contact us at: support@oulta.org'),

                 SizedBox(height: 24),
                _Heading(text: '9. Updates to This Policy'),
                 SizedBox(height: 12),
                _BodyText(text: 'We may update this Privacy Policy occasionally. The revised version will be posted on this page with the updated “Last Updated” date. Significant changes will be announced in the app or via email.'),

              ],
            ),
          ),
        ),
      ),
    );
  }
}


// Helper widgets for styling
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

class _SubHeading extends StatelessWidget {
  final String text;
  const _SubHeading({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
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
