import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/app/home/tasks/edit_task_page.dart';
import 'package:task_manager/app/home/tasks/task_list_tile.dart';
import 'package:task_manager/app/home/tasks/list_items_builder.dart';
import 'package:task_manager/app/home/models/task.dart';
import 'package:task_manager/common_widgets/platform_exception_alert_dialog.dart';
import 'package:task_manager/services/database.dart';
import 'package:flutter/services.dart';

class TasksPage extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () => EditTaskPage.show(
              context,
              task: null,
              database: Provider.of<Database>(context),
            ),
          ),
        ],
      ),
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context);
    return StreamBuilder<List<Task>>(
      stream: database.tasksStream(),
      builder: (context, snapshot) {
        return ListItemsBuilder<Task>(
          snapshot: snapshot,
          itemBuilder: (context, task) => Dismissible(
            background: Container(
              color: Colors.red,
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _deleteMethod(context, task),
            key: Key('task-${task.id}'),
            child: TaskListTile(
              task: task,
              // onTap: () => TaskEntriesPage.show(context, task),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteMethod(BuildContext context, Task task) async {
    try {
      final database = Provider.of<Database>(context);
      await database.deleteTask(task);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Sign in failed',
        exception: e,
      ).show(context);
    }
  }
}
