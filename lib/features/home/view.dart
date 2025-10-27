import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/features/home/widgets/oulta_circle.dart';
import '../../common/routes/routename.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/oulta_des_card.dart';
import '../../common/widgets/small_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'OULTA',
          // onLeadingIconPressed: () {
          //   print('Explore Screen: Leading icon pressed');
          // },
          trailingIcon : Icons.settings,
          leadingIcon : Icons.person,
          onTrailingIconPressed: () {
              Get.toNamed(RouteName.settings);
            },
          onLeadingIconPressed: () {
              Get.toNamed(RouteName.account);
            },
        ),
        body: SingleChildScrollView(
          child: Column(
            children:  [
              SizedBox(height: 10),
              OultaCircle(),
            ],
          ),
        ),
      ),
    );
  }
}

// class CardsScreen extends StatelessWidget {
//   const CardsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final horizontalPadding = 20.0;
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 18),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1), // soft shadow
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: const Offset(0, 4), // shadow below
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             BigCard(
//               title: 'Worldcoin',
//               actionText: 'Buy',
//               priceText: '₹ 120',
//               percentText: '0.04%',
//             ),
//             const SizedBox(height: 18),
//             Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       Get.toNamed(RouteName.app_detail_screen);
//                     },
//                     child: SmallCard(
//                       accentIcon: Icons.attach_money,
//                       title: 'Cash',
//                       actionText: 'Deposit',
//                       iconBackgroundColor: const Color(0xFF00C853),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: SmallCard(
//                     accentIcon: Icons.monetization_on,
//                     title: 'Coins',
//                     actionText: 'Deposit',
//                     iconBackgroundColor: const Color(0xFF2979FF),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



