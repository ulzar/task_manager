import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_manager/app/home/task_entries/format.dart';
import 'package:task_manager/app/home/models/entry.dart';
import 'package:task_manager/app/home/models/task.dart';
import 'package:task_manager/common_widgets/date_time_picker.dart';
import 'package:task_manager/common_widgets/platform_exception_alert_dialog.dart';
import 'package:task_manager/services/database.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({@required this.database, @required this.task, this.entry});
  final Task task;
  final Entry entry;
  final Database database;

  static Future<void> show({BuildContext context, Database database, Task task, Entry entry}) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) =>
            EntryPage(database: database, task: task, entry: entry),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {

  DateTime _creationDate;
  String _completionDetail;
  bool _completed;
  bool _important;

  @override
  void initState() {
    super.initState();

    _creationDate = widget.entry?.creationDate ?? null;
    _completed = widget.entry?.completed ?? false;
    _important = widget.entry?.important ?? false;
    _completionDetail = widget.entry?.completionDetail ?? '';
  }

  Entry _entryFromState() {
  
    final id = widget.entry?.id ?? documentIdFromCurrentDate();
    return Entry(
      id: id,
      taskId: widget.task.id,
      important: _important,
      creationDate: _creationDate,
      completed: _completed,
      completionDetail: _completionDetail,
   
    );
  }

  Future<void> _setEntryAndDismiss(BuildContext context) async {
    try {
      final entry = _entryFromState();
      await widget.database.setEntry(entry);
      Navigator.of(context).pop();
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(widget.task.name),
        actions: <Widget>[
          FlatButton(
            child: Text(
              widget.entry != null ? 'Update' : 'Create',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            onPressed: () => _setEntryAndDismiss(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildComment(),
            ],
          ),
        ),
      ),
    );
  }




  Widget _buildComment() {
    return TextField(
      keyboardType: TextInputType.text,
      maxLength: 50,
      controller: TextEditingController(text: _completionDetail),
      decoration: InputDecoration(
        labelText: 'Completion Detail',
        labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      ),
      style: TextStyle(fontSize: 20.0, color: Colors.black),
      maxLines: null,
      onChanged: (completionDetail) => _completionDetail = completionDetail,
    );
  }
}
