import 'package:flutter/material.dart';
import 'package:task_manager/app/home/cupertino_home_scaffold.dart';
import 'package:task_manager/app/home/tab_items.dart';
import 'package:task_manager/app/home/tasks/tasks_page.dart';
import 'package:task_manager/app/home/entries/entries_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.dailyEntries;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.dailyEntries: GlobalKey<NavigatorState>(),
    TabItem.tasks: GlobalKey<NavigatorState>(),
    TabItem.calendar: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.dailyEntries: (_) => EntriesPage.create(context),
      TabItem.tasks: (_) => TasksPage(),
      TabItem.calendar: (_) => Container(),
      TabItem.account: (_) => Container(),
    };
  }

  void _select(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // pop to first route
      navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    }
    print(tabItem.toString());
    setState(() => _currentTab = tabItem);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[_currentTab].currentState.maybePop(),
      child: CupertinoHomeScaffold(
        navigatorKeys: navigatorKeys,
        currentTab: _currentTab,
        onSelectTab: _select,
        widgetBuilders: widgetBuilders,
      ),
    );
  }
}
