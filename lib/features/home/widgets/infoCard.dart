
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get.dart';
import '../../../common/routes/routename.dart';
import '../../../common/widgets/oulta_des_card.dart';
import '../../../common/widgets/small_card.dart';

class InfoCard extends StatelessWidget {
  final String heading;
  final String description;
  final Color backgroundColor;

  const InfoCard({
    super.key,
    required this.heading,
    required this.description,
    this.backgroundColor = const Color(0xFFE3F2FD),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OultaDescCard(title: heading, desc: description,),
        SizedBox(height: 15,),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(RouteName.app_detail_screen);
                },
                child: SmallCard(
                  accentIcon: Icons.attach_money,
                  title: 'Cash',
                  actionText: 'Deposit',
                  iconBackgroundColor: const Color(0xFF00C853),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SmallCard(
                accentIcon: Icons.monetization_on,
                title: 'Coins',
                actionText: 'Deposit',
                iconBackgroundColor: const Color(0xFF2979FF),
              ),
            ),
          ],
        ),
        SizedBox(height: 15,),
        SizedBox(height: 15,),
        SizedBox(height: 15,),


        //      CardsScreen()
      ],
    );
  }
}