import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class BalanceCard extends StatelessWidget {
  final String balance;
  final String accountNumber;

  const BalanceCard({
    required this.balance, required this.accountNumber, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'availableBalance'.tr,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            balance,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${'accountLabel'.tr} $accountNumber',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
