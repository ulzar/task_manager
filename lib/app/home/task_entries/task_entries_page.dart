import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:task_manager/app/home/task_entries/entry_list_item.dart';
import 'package:task_manager/app/home/task_entries/entry_page.dart';
import 'package:task_manager/app/home/tasks/edit_task_page.dart';
import 'package:task_manager/app/home/tasks/list_items_builder.dart';
import 'package:task_manager/app/home/models/entry.dart';
import 'package:task_manager/app/home/models/task.dart';
import 'package:task_manager/common_widgets/platform_exception_alert_dialog.dart';
import 'package:task_manager/services/database.dart';

class TaskEntriesPage extends StatelessWidget {
  const TaskEntriesPage({@required this.database, @required this.task});
  final Database database;
  final Task task;

  static Future<void> show(BuildContext context, Task task) async {
    final Database database = Provider.of<Database>(context);
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: false,
        builder: (context) => TaskEntriesPage(database: database, task: task),
      ),
    );
  }

  Future<void> _deleteEntry(BuildContext context, Entry entry) async {
    try {
      await database.deleteEntry(entry);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Task>(
        initialData: task,
        stream: database.taskStream(taskId: task.id),
        builder: (context, snapshot) {
          final task = snapshot.data;
          final taskName = task?.name ?? '';
          return Scaffold(
            appBar: AppBar(
              elevation: 2.0,
              title: Text(taskName),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () =>
                      EditTaskPage.show(context, task: task, database: database),
                ),
                // IconButton(
                //   icon: Icon(Icons.add, color: Colors.white),
                //   onPressed: () =>
                //       EditTaskPage.show(context, task: task, database: database),
                // ),
              ],
            ),
            body: _buildContent(context, task),
          );
        });
  }

  Widget _buildContent(BuildContext context, Task task) {
    return StreamBuilder<List<Entry>>(
      stream: database.entriesStream(task: task),
      builder: (context, snapshot) {
        return ListItemsBuilder<Entry>(
          snapshot: snapshot,
          itemBuilder: (context, entry) {
            return DismissibleEntryListItem(
              key: Key('entry-${entry.id}'),
              entry: entry,
              task: task,
              onDismissed: () => _deleteEntry(context, entry),
              // onTap: () => EntryPage.show(
              //   context: context,
              //   database: database,
              //   task: task,
              //   entry: entry,
              // ),
            );
          },
        );
      },
    );
  }
}
