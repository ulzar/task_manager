import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/app/home/tab_items.dart';

class CupertinoHomeScaffold extends StatelessWidget {
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;
  final Map<TabItem, WidgetBuilder> widgetBuilders;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys;

  const CupertinoHomeScaffold(
      {Key key, @required this.currentTab, @required this.onSelectTab,@required  this.widgetBuilders, this.navigatorKeys})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          _buildItem(TabItem.dailyEntries),
          _buildItem(TabItem.tasks),
          _buildItem(TabItem.account),
        ],
        onTap: (index) => onSelectTab(TabItem.values[index]),
      ),
      tabBuilder: (context, index) {
        final item = TabItem.values[index];
        return CupertinoTabView(
          navigatorKey: navigatorKeys[item],
          builder: (context) => widgetBuilders[item](context),
        );
      },
    );
  }

  BottomNavigationBarItem _buildItem(TabItem tabItem) {
    final itemData = TabItemData.allTabs[tabItem];
    final color = currentTab == tabItem ? Colors.indigo : Colors.grey;
    return BottomNavigationBarItem(
      icon: Icon(itemData.icon, color: color,),
      title: Text(itemData.title,style: TextStyle(color: color)),
    );
  }
}
