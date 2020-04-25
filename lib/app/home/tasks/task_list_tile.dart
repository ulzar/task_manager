import 'package:flutter/material.dart';
import 'package:task_manager/app/home/models/task.dart';

class TaskListTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskListTile({Key key, this.task, this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.name),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}