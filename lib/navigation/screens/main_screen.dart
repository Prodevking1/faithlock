import 'package:faithlock/navigation/controllers/navigation_controller.dart';
import 'package:faithlock/shared/widgets/bars/fast_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatelessWidget {
  final NavigationController controller = Get.put(NavigationController());
  MainScreen();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        controller.onWillPop();
      },
      child: Obx(
        () => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex,
            children:
                controller.navigationItems.map((item) => item.page).toList(),
          ),
          bottomNavigationBar: FastBottomBar(
            currentIndex: controller.currentIndex,
            onTap: controller.changePage,
            items: controller.bottomBarItems,
          ),
        ),
      ),
    );
  }
}
