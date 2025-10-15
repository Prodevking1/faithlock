import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Card widget to display individual benefits with attractive styling
class BenefitCard extends StatelessWidget {
  final String text;
  final int index;
  final bool isIOS;

  const BenefitCard({
    super.key,
    required this.text,
    required this.index,
    required this.isIOS,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isIOS ? CupertinoColors.systemBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isIOS ? CupertinoColors.systemGrey5 : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isIOS
                ? CupertinoColors.systemGrey.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Check icon with gradient background
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isIOS ? CupertinoColors.systemGreen : Colors.green,
                  isIOS ? CupertinoColors.systemTeal : Colors.teal,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIOS ? CupertinoIcons.checkmark : Icons.check,
              size: 14,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 16),

          // Benefit text
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isIOS ? CupertinoColors.label : Colors.grey[800],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
