import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/app/home/models/task.dart';
import 'package:task_manager/app/home/models/task.dart';
import 'package:task_manager/common_widgets/input_dropdown.dart';
import 'package:task_manager/common_widgets/platform_alert_dialog.dart';
import 'package:task_manager/common_widgets/platform_exception_alert_dialog.dart';
import 'package:task_manager/services/database.dart';

class EditTaskPage extends StatefulWidget {
  const EditTaskPage({Key key, @required this.database, this.task})
      : super(key: key);
  final Database database;
  final Task task;

  static Future<void> show(BuildContext context,
      {Task task, Database database}) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => EditTaskPage(database: database, task: task),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  TaskType _type = TaskType.oneoff;
  TaskRecurrence _recurrence = TaskRecurrence.everyMonday;
  bool _important = false;

  @override
  void initState() {
    super.initState();

    // _type = TaskType.oneoff;
    // _recurrence = TaskRecurrence.everyMonday;


    if (widget.task != null) {
      _name = widget.task.name;
      _type = widget.task.type ?? TaskType.oneoff;
      _recurrence = widget.task.recurrence ?? TaskRecurrence.everyMonday;
      _important = widget.task.important ?? false;
    }
  }

  bool _isCreateForm() => widget.task == null;

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        final tasks = await widget.database.tasksStream().first;
        final allNames = tasks.map((task) => task.name).toList();

        if (_isCreateForm() && allNames.contains(_name)) {
          PlatformAlertDialog(
            title: 'Name already in user',
            content: 'Please choose a different task name',
            defaultActionText: 'OK',
          ).show(context);
        } else {
          print(
              'form saved, name: $_name, _recurrence: $_recurrence, _type: $_type, _important: $_important');
          final id = widget.task?.id ?? documentIdFromCurrentDate();
          final task = Task(
            id: id,
            name: _name,
            recurrence: _recurrence,
            type: _type,
            important: _important,
          );
          await widget.database.setTask(task);
          Navigator.of(context).pop();
        }
      } on PlatformException catch (e) {
        PlatformExceptionAlertDialog(
          title: 'Sign in failed',
          exception: e,
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(_isCreateForm() ? 'New Task' : 'Edit Task'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Save',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            onPressed: _submit,
          ),
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    const fontSize = 16.0;
    return [
      TextFormField(
          initialValue: _name,
          decoration: InputDecoration(labelText: 'Task name'),
          validator: (value) {
            if (value.isEmpty) {
              return  'Name can\'t be empty';
            }

            if (value.length < 5) {
              return 'Please provide a name with at least 5 characters';
            }
            return null;
          },
          onSaved: (value) => _name = value,
          style: TextStyle(fontSize: fontSize)),
      SizedBox(height: 12.0),
      _buildTaskTypeChild(context, fontSize),
      SizedBox(height: 12.0),
      if (_type == TaskType.recurring) ...[
        _buildTaskRecurrenceChild(context, fontSize),
        SizedBox(height: 12.0),
      ],
      CheckboxListTile(
        title: Text("Mark as important"), //    <-- label
        value: _important,
        onChanged: (newValue) {
          setState(() {
            _important = newValue;
          });
        } ,
      ),
    ];
  }

  Widget _buildTaskTypeChild(BuildContext context, double fontSize) {
    return DropdownButton<TaskType>(
        isExpanded: true,
        value: _type,
        onChanged: (TaskType newValue) {
          setState(() {
            _type = newValue;
          });
        },
        items: TaskType.values.map((TaskType classType) {
          final taskTypeString = taskTypeStrings[classType];
          return DropdownMenuItem<TaskType>(
              value: classType,
              child:
                  Text(taskTypeString, style: TextStyle(fontSize: fontSize)));
        }).toList(),
      );
  }

  _onTaskRecurrenceChange(TaskRecurrence newValue) {
        setState(() {
          _recurrence = newValue;
        });
      }

  Widget _buildTaskRecurrenceChild(BuildContext context, double fontSize) {
    return DropdownButton<TaskRecurrence>(
      
      isExpanded: true,
      value: _recurrence,
      onChanged: _isCreateForm() ? _onTaskRecurrenceChange : null,
      items: TaskRecurrence.values.map((TaskRecurrence classType) {
        final taskRecurrenceString = taskRecurrenceStrings[classType];
        return DropdownMenuItem<TaskRecurrence>(
            value: classType,
            child: Text(taskRecurrenceString,
                style: TextStyle(fontSize: fontSize)));
      }).toList(),
    );
  }
}
