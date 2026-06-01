import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Oulta Support'),
            const SizedBox(height: 16),
            _buildBodyText(
              context,
              'We’re here to help you make an impact — smoothly, clearly, and with care. If you ever face an issue or have a question, our team and community are always ready to support you.',
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Need Help?'),
            const SizedBox(height: 16),
            _buildBodyText(
              context,
              'We’re always listening. Whether it’s a technical issue, feedback, or something you don’t understand — just reach out. We’ll do our best to guide you quickly and kindly.',
            ),
            const SizedBox(height: 16),
            _buildBodyText(context, 'Email: support@oulta.org'),
            _buildBodyText(context, 'Website: oulta.org'),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Community First'),
            const SizedBox(height: 16),
            _buildBodyText(
              context,
              'Oulta is built around collaboration and kindness. Before you reach out, you can also connect with other members — many questions get solved faster when we help each other. Together, we keep the Oulta spirit alive.',
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Frequently Asked Questions'),
            const SizedBox(height: 24),
            _buildFaqItem(
              context,
              'What is Oulta?',
              'Oulta is a global movement where people, brands, and causes come together to create measurable social good. Every act of kindness and contribution counts — and is reflected through your Dharma Points.',
            ),
            _buildFaqItem(
              context,
              'What are Dharma Points?',
              'Dharma Points show how much positive impact you’ve made through Oulta. They represent your contribution to society and our shared mission to help humanity thrive together.',
            ),
            _buildFaqItem(
              context,
              'I can’t see my recent activity or points.',
              'Don’t worry — sometimes updates take a short while to appear. Try refreshing the app or checking again later. If it still doesn’t show up, contact our support team, and we’ll help right away.',
            ),
            _buildFaqItem(
              context,
              'How can I partner or collaborate with Oulta?',
              'We love working with people, NGOs, and brands that want to make real impact. Just reach out at partnerships@oulta.org with a short message about what you do — we’ll get back to you soon.',
            ),
            _buildFaqItem(
              context,
              'I found a bug or issue. What should I do?',
              'Please send details (with screenshots if possible) to support@oulta.org. We’ll look into it as soon as we can — your feedback helps us improve for everyone.',
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Thank You'),
             const SizedBox(height: 16),
            _buildBodyText(
              context,
              'Every message you send, every suggestion you share — helps Oulta grow stronger. You’re part of a community that’s shaping a more caring and connected world.',
            ),
             const SizedBox(height: 16),
            Center(
              child: Text(
              'Together, we make impact possible.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
            ),),
             const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildBodyText(BuildContext context, String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Colors.black87.withOpacity(0.85),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: Colors.black87.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }
}
