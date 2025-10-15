// src/lib/config/ui/navigation_config.dart
//
// This file defines the navigation configuration for the app, including
// the structure of navigation items and the standard bottom navigation items.
// It provides a centralized place to manage navigation-related constants,
// making it easier to update navigation elements throughout the app.

import 'package:flutter/material.dart';

/// Represents a single navigation item for use in navigation components.
///
/// Each item contains all the necessary information for rendering navigation
/// elements like bottom navigation bars, drawers, or tabs.
class NavigationItem {
  final String id;
  final String label;
  final IconData icon;
  final String route;
  final int index;

  const NavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    required this.index,
  });
}

/// Provides configuration constants for navigation throughout the app.
///
/// This class centralizes navigation-related constants to ensure consistency
/// across different parts of the application.
class NavigationConfig {
  /// Standard items for the bottom navigation bar.
  ///
  /// These items define the main sections of the application that are
  /// accessible from the persistent bottom navigation.
  static const List<NavigationItem> bottomNavItems = [
    NavigationItem(
      id: 'home',
      label: 'Home',
      icon: Icons.home,
      route: '/home',
      index: 0,
    ),
    NavigationItem(
      id: 'wallet',
      label: 'Wallet',
      icon: Icons.account_balance_wallet,
      route: '/wallet',
      index: 1,
    ),
    NavigationItem(
      id: 'scanner',
      label: 'Scanner',
      icon: Icons.qr_code_scanner,
      route: '/scanner',
      index: 2,
    ),
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person,
      route: '/profile',
      index: 3,
    ),
  ];
}
