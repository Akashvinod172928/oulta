import 'package:flutter/material.dart';

class WhatIsDharmaScreen extends StatelessWidget {
  const WhatIsDharmaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What is Dharma?'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is Dharma?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 24),
            _buildBodyText(
              context,
              'Dharma Points are a reflection of your positive impact through Oulta. They represent how your choices and actions contribute to a better world — one built on compassion, collaboration, and purpose.',
            ),
            const SizedBox(height: 16),
            _buildBodyText(
              context,
              'Dharma isn\'t about money or status. It\'s about meaning — about what we create together when everyone decides to help, care, and act for good.',
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Why It Matters'),
            const SizedBox(height: 16),
            _buildBodyText(
              context,
              'Oulta believes humanity can thrive when we act together. Dharma is the new measure of that collective progress — a shared signal of hope and contribution in an age where technology connects us all.',
            ),
            const SizedBox(height: 16),
            _buildBodyText(
              context,
              'Every point is a reminder: we\'re not alone in trying to make things better.',
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Your Impact, Your Legacy'),
            const SizedBox(height: 16),
            _buildBodyText(
              context,
              'Your Dharma grows as you continue to do good through Oulta. It\'s a living record of your values — proof that you chose action over apathy, kindness over indifference.',
            ),
            const SizedBox(height: 24),
            _buildBodyText(
              context,
              'Together, we\'re building a new order — one where doing good is the highest form of success.',
              isBold: true,
            ),
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
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: Colors.black87.withOpacity(0.85),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
    );
  }
}
