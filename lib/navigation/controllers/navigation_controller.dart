import 'package:faithlock/config/logger.dart';
import 'package:faithlock/features/faithlock/screens/stats_dashboard_screen.dart';
import 'package:faithlock/features/faithlock/screens/verse_library_screen.dart';
import 'package:faithlock/features/profile/screens/profile_screen.dart';
import 'package:faithlock/navigation/models/bottom_nav_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  static NavigationController get to => Get.find();

  final RxInt _currentIndex = 0.obs;
  final RxList<BottomNavItem> _navigationItems = <BottomNavItem>[].obs;

  int get currentIndex => _currentIndex.value;
  List<BottomNavItem> get navigationItems => _navigationItems;

  @override
  void onInit() {
    super.onInit();
    _initializeNavigationItems();
  }

  void _initializeNavigationItems() {
    _navigationItems.value = [
      BottomNavItem(
        label: 'Stats',
        icon: CupertinoIcons.chart_bar,
        activeIcon: CupertinoIcons.chart_bar_fill,
        route: '/stats',
        page: StatsDashboardScreen(),
      ),
      BottomNavItem(
        label: 'Library',
        icon: CupertinoIcons.book,
        activeIcon: CupertinoIcons.book_fill,
        route: '/library',
        page: const VerseLibraryScreen(),
      ),
      BottomNavItem(
        label: 'Profile',
        icon: CupertinoIcons.person,
        activeIcon: CupertinoIcons.person_fill,
        route: '/profile',
        page: ProfileScreen(),
      ),
    ];
  }

  void changePage(int index) {
    if (index < 0 || index >= _navigationItems.length) {
      logger.error('Invalid navigation index: $index');
      return;
    }

    _currentIndex.value = index;
  }

  Widget get currentPage => _navigationItems[currentIndex].page;

  List<BottomNavigationBarItem> get bottomBarItems => _navigationItems
      .map((item) => BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.activeIcon),
            label: item.label,
          ))
      .toList();

  Future<bool> onWillPop() async {
    if (currentIndex != 0) {
      changePage(0);
      return false;
    }
    return true;
  }
}
