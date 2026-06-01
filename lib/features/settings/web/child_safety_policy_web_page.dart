import 'package:flutter/material.dart';
import 'package:oulta/common/widgets/custom_app_bar.dart';

class ChildSafetyPolicyWebPage extends StatelessWidget {
  const ChildSafetyPolicyWebPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Child Safety & Protection Policy',
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
                  'Last updated: 12/11/2025',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black54),
                ),
                SizedBox(height: 16),
                _BodyText(
                  text: 'At OULTA, we are committed to maintaining a safe environment for all users. We have zero tolerance for child sexual abuse and exploitation (CSAE) or any harmful content involving minors.',
                ),
                SizedBox(height: 24),
                _Heading(text: '1. Protection of Minors'),
                SizedBox(height: 12),
                _BodyText(text: 'OULTA strictly prohibits:'),
                _BulletPoint(text: 'Any content, imagery, or language depicting the sexual exploitation or abuse of children.'),
                _BulletPoint(text: 'Solicitation, grooming, or communication intended to exploit or harm minors.'),
                _BulletPoint(text: 'Accounts, groups, or discussions that encourage, share, or normalize CSAE material.'),
                _BodyText(text: 'Violations lead to immediate removal of content and permanent account suspension.'),
                SizedBox(height: 24),
                _Heading(text: '2. Detection & Reporting'),
                SizedBox(height: 12),
                _BulletPoint(text: 'Users can report harmful or suspicious content directly in the app using the “Report” or “Support” option.'),
                _BulletPoint(text: 'All CSAE-related reports are reviewed with the highest priority.'),
                _BulletPoint(text: 'Confirmed cases are reported to relevant law enforcement and national child protection authorities in accordance with applicable laws.'),
                _BulletPoint(text: 'OULTA cooperates fully with international and regional organizations that combat child sexual abuse material (CSAM).'),
                SizedBox(height: 24),
                _Heading(text: '3. No Child-Directed Features'),
                SizedBox(height: 12),
                _BodyText(text: 'OULTA is designed for users 16 years and older and does not intentionally collect data from minors. If any child data is discovered, it will be deleted immediately.'),
                SizedBox(height: 24),
                _Heading(text: '4. Continuous Commitment'),
                SizedBox(height: 12),
                _BodyText(text: 'We work to ensure:'),
                _BulletPoint(text: 'Regular moderation and review of public content.'),
                _BulletPoint(text: 'Staff awareness and training on CSAM detection and response.'),
                _BulletPoint(text: 'Compliance with all applicable child safety and online harm laws.'),
                SizedBox(height: 24),
                _Heading(text: '5. Contact for Child Safety Concerns'),
                SizedBox(height: 12),
                _BodyText(text: 'If you have concerns or reports related to child safety or exploitation, please contact our Child Safety Officer at: vinodakash604@gmail.com'),
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
