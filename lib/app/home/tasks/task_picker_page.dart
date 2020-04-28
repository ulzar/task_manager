import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/app/home/models/entry.dart';
import 'package:task_manager/app/home/models/task.dart';
import 'package:task_manager/app/home/entries/entries_bloc.dart';
import 'package:task_manager/app/home/tasks/list_items_builder.dart';
import 'package:task_manager/common_widgets/platform_exception_alert_dialog.dart';
import 'package:task_manager/services/database.dart';
import 'package:task_manager/services/day_controller.dart';

class TaskPickerPage extends StatefulWidget {
  const TaskPickerPage({@required this.database, @required this.bloc, @required this.dayController}):
  assert(database != null) , assert(bloc != null), assert(dayController != null);
  final Database database;
  final EntriesBloc bloc;
  final DayController dayController;
  static Future<void> show({
    BuildContext context,
  }) async {
    final database = Provider.of<Database>(context);
    final bloc = Provider.of<EntriesBloc>(context);
    final dayController = Provider.of<DayController>(context);
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => TaskPickerPage(database: database, bloc: bloc, dayController: dayController),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _TaskPickerPage();
}

class _TaskPickerPage extends State<TaskPickerPage> {
  final Map<String, bool> checkedTasks = new Map<String, bool>();
  final Map<String, Task> taskMap = new Map<String, Task>();

  // DateTime _creationDate;
  // String _completionDetail;
  // bool _completed;
  // bool _important;

  // @override
  // void initState() {
  //   super.initState();

  //   _creationDate = widget.entry?.creationDate ?? null;
  //   _completed = widget.entry?.completed ?? false;
  //   _important = widget.entry?.important ?? false;
  //   _completionDetail = widget.entry?.completionDetail ?? '';
  // }

  // Entry _entryFromState() {
  //   final id = widget.entry?.id ?? documentIdFromCurrentDate();
  //   return Entry(
  //     id: id,
  //     taskId: widget.task.id,
  //     important: _important,
  //     creationDate: _creationDate,
  //     completed: _completed,
  //     completionDetail: _completionDetail,
  //   );
  // }

  Future<void> _setEntryAndDismiss(BuildContext context) async {
    print(checkedTasks);
    try {
      final currentDay = widget.dayController.currentDay;
      final List<Entry> newEntries = new List<Entry>();
      checkedTasks.forEach((String taskId, bool checked) {
        if (!checked) {
          return;
        }
        final task = taskMap[taskId];
        newEntries.add(task.createEntry(currentDay));
      });

      for (var entry in newEntries) {
        print("Event received: $entry");
        await widget.database.setEntry(entry);
      }

      Navigator.of(context).pop();
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  void _taskToggled(Task task, bool checked) {
    print('_taskToggled: ${task.id} - $checked');
    print(checkedTasks);
    checkedTasks[task.id] = checked;
  }

  Widget _buildContents(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: widget.bloc.availableUnselectedTasks,
      builder: (context, snapshot) {
        return ListItemsBuilder<Task>(
            snapshot: snapshot,
            itemBuilder: (context, task) {
              taskMap[task.id] = task;
              return CheckboxListTile(
                title: Text(task.name), //    <-- label
                value: checkedTasks[task.id] ?? false,
                onChanged: (newValue) {
                  setState(() {
                    _taskToggled(task, newValue);
                  });
                },
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("build task picker page");
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text('Select tasks to add'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Add',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            onPressed: () => _setEntryAndDismiss(context),
          )
        ],
      ),
      body: _buildContents(context),
    );
  }
}
