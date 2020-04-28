import 'package:flutter/material.dart';
import 'package:task_manager/app/home/models/entry.dart';
import 'package:task_manager/app/home/models/task.dart';

class EntryListTile extends StatelessWidget {
  final Entry entry;
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const EntryListTile(
      {Key key,
      @required this.entry,
      @required this.task,
      this.onTap,
      this.onLongPress})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: entry.completed ? Colors.blue[200] : Colors.grey[50],
      child: ListTile(
        contentPadding: EdgeInsets.all(12.0),
        title: Text(task.name),
        trailing: entry.important
            ? Icon(Icons.star, color: Colors.yellow)
            : Icon(Icons.star_border, color: Colors.yellow[100]),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
