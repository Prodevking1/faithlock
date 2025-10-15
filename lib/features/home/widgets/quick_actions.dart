import 'package:flutter/cupertino.dart';
import 'package:faithlock/core/helpers/ui_helper.dart';
import 'package:get/get.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  void _showTransferDialog(BuildContext context) {
    UIHelper.showAlertDialog(
      title: 'newTransfer'.tr,
      message: 'enterTransferDetails'.tr,
      confirmText: 'validate'.tr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoFormSection.insetGrouped(
      header: Text('quickActions'.tr),
      children: <Widget>[
        CupertinoFormRow(
          prefix: const Icon(CupertinoIcons.arrow_right_arrow_left),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showTransferDialog(context),
            child: Text('newTransfer'.tr),
          ),
        ),
        CupertinoFormRow(
          prefix: const Icon(CupertinoIcons.creditcard),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: Text('payByCard'.tr),
          ),
        ),
      ],
    );
  }
}
