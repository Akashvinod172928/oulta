import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AccountShimmer extends StatelessWidget {
  const AccountShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey, // Visible color
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 20,
                      color: Colors.grey, // Visible color
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 16,
                      color: Colors.grey, // Visible color
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 50,
              color: Colors.grey, // Visible color
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 50,
              color: Colors.grey, // Visible color
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 50,
              color: Colors.grey, // Visible color
            ),
          ],
        ),
      ),
    );
  }
}
