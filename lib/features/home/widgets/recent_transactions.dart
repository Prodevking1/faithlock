import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoFormSection.insetGrouped(
      children: <Widget>[
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.shopping_cart),
          title: Text('supermarket'.tr),
          subtitle: Text('yesterday'.tr),
          trailing: const Text('-42.50 €'),
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.arrow_down_circle),
          title: Text('salary'.tr),
          subtitle: const Text('28/02/2024'),
          trailing: const Text('+2,450.00 €'),
        ),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.car),
          title: Text('gas'.tr),
          subtitle: const Text('27/02/2024'),
          trailing: const Text('-65.30 €'),
        ),
      ],
    );
  }
}
