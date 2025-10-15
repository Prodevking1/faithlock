import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ProfileSection {
  final String title;
  final IconData? icon;
  final List<ProfileItem> items;
  final bool isExpandable;

  const ProfileSection({
    required this.title,
    this.icon,
    required this.items,
    this.isExpandable = true,
  });
}

class ProfileItem {
  final String title;
  final String? description;
  final IconData? icon;
  final Function()? onTap;
  final Widget? trailing;
  final bool isDividerVisible;
  final Color? titleColor;
  final Color? iconColor;

  const ProfileItem({
    required this.title,
    this.description,
    this.icon,
    this.onTap,
    this.trailing,
    this.isDividerVisible = true,
    this.titleColor,
    this.iconColor,
  });
}
