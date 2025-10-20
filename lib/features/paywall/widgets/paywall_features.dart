// import 'package:faithlock/core/constants/core/fast_colors.dart';
// import 'package:flutter/material.dart';

// /// Premium features showcase widget
// class PaywallFeatures extends StatelessWidget {
//   const PaywallFeatures({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const Text(
//           'Unlock Premium Features',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//             height: 1.3,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 6),
//         Text(
//           'Get unlimited access to all premium features',
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey[600],
//             height: 1.4,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 20),
//         _buildFeaturesList(),
//       ],
//     );
//   }

//   Widget _buildFeaturesList() {
//     final features = [
//       _FeatureItem(
//         icon: Icons.star,
//         title: 'Premium Content',
//         description: 'Access to exclusive premium content and features',
//       ),
//       _FeatureItem(
//         icon: Icons.cloud_sync,
//         title: 'Cloud Sync',
//         description: 'Sync your data across all devices automatically',
//       ),
//     ];

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListView.separated(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: features.length,
//         itemBuilder: (context, index) => _buildFeatureRow(features[index]),
//         separatorBuilder: (context, index) => const SizedBox(height: 24),
//       ),
//     );
//   }

//   Widget _buildFeatureRow(_FeatureItem feature) {
//     return Row(
//       children: [
//         // Icon
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: feature.iconColor.withValues(alpha: 0.12),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             feature.icon,
//             color: feature.iconColor,
//             size: 22,
//           ),
//         ),
//         const SizedBox(width: 12),
//         // Texts
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 feature.title,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 feature.description,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey[600],
//                   height: 1.3,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 8),
//         // Checkmark
//         Container(
//           width: 24,
//           height: 24,
//           decoration: BoxDecoration(
//             color: const Color(0xFF00C896),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Icon(
//             Icons.check,
//             color: Colors.white,
//             size: 14,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _FeatureItem {
//   final IconData icon;
//   final Color iconColor;
//   final String title;
//   final String description;

//   _FeatureItem({
//     required this.icon,
//     this.iconColor = FastColors.primary,
//     required this.title,
//     required this.description,
//   });
// }
