import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum TabItem { dailyEntries, tasks, calendar, account }

class TabItemData {
  final String title;
  final IconData icon;

  const TabItemData({@required this.title, @required this.icon});

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.dailyEntries: TabItemData(title: 'DailyEntries', icon: Icons.calendar_view_day),
    TabItem.tasks: TabItemData(title: 'Tasks', icon: Icons.view_headline),
    TabItem.calendar: TabItemData(title: 'Calendar', icon: Icons.calendar_today),
    TabItem.account: TabItemData(title: 'Account', icon: Icons.person),
  };
}
