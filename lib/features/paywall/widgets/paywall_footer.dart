// import 'package:faithlock/features/paywall/controllers/paywall_controller.dart';
// import 'package:flutter/material.dart';

// /// Paywall footer with terms, privacy policy and subscription info
// class PaywallFooter extends StatelessWidget {
//   final PaywallController controller;

//   const PaywallFooter({
//     super.key,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return _buildTermsSection();
//   }

//   Widget _buildTermsSection() {
//     return Column(
//       children: [
//         Wrap(
//           alignment: WrapAlignment.center,
//           children: [
//             _buildTermsLink('Privacy Policy'),
//             Text(
//               ' • ',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey[400],
//               ),
//             ),
//             _buildTermsLink('Terms of Service'),
//             Text(
//               ' • ',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey[400],
//               ),
//             ),
//             _buildTermsLink('Subscription Terms'),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Text(
//           'By continuing, you accept our terms and policies',
//           style: TextStyle(
//             fontSize: 13,
//             color: Colors.grey[600],
//             height: 1.4,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildTermsLink(String text) {
//     VoidCallback? onTap;

//     switch (text) {
//       case 'Privacy Policy':
//         onTap = controller.openPrivacyPolicy;
//         break;
//       case 'Terms of Service':
//         onTap = controller.openTermsOfService;
//         break;
//       case 'Subscription Terms':
//         onTap = controller.openSubscriptionTerms;
//         break;
//     }

//     return GestureDetector(
//       onTap: onTap,
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 13,
//           color: Colors.grey[600],
//           decoration: TextDecoration.underline,
//           decorationColor: Colors.grey[400],
//         ),
//       ),
//     );
//   }
// }
