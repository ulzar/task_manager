import 'package:meta/meta.dart';
import 'package:task_manager/app/home/models/entry.dart';
import 'package:task_manager/services/database.dart';

enum TaskType { recurring, oneoff }
enum TaskRecurrence { everyDay, everyMonday, everyBusinessDay, everyWeekend }

final Map<TaskType, String> taskTypeStrings = {
  TaskType.recurring: "Recurring",
  TaskType.oneoff: "One-off",
};

final Map<TaskRecurrence, String> taskRecurrenceStrings = {
  TaskRecurrence.everyDay: "Everyday",
  TaskRecurrence.everyMonday: "Every Monday",
  TaskRecurrence.everyBusinessDay: "Every business day",
  TaskRecurrence.everyWeekend: "Every weekend",
};

class Task {
  Task({
    @required this.id,
    @required this.name,
    @required this.type,
    @required this.important,
    this.recurrence,
  });
  final String id;
  final String name;
  final TaskRecurrence recurrence;
  final TaskType type;
  final bool important;

  Entry createEntry(DateTime currentDay) {
    return Entry(
      id: documentIdFromCurrentDate(),
      creationDate: currentDay,
      taskId: id,
      important: important,
    );
  }

  static TaskRecurrence recurrenceFromString(dynamic input) {
    final values = taskRecurrenceStrings.values.toList();
    for (var i = 0; i < values.length; i++) {
      if (values[i] ==input ) {
        return taskRecurrenceStrings.keys.toList()[i];
      }
    }
    return TaskRecurrence.everyMonday;
  }

  static TaskType typeFromString(dynamic input) {
    final values = taskTypeStrings.values.toList();
    for (var i = 0; i < values.length; i++) {
      if (values[i] ==input ) {
        return taskTypeStrings.keys.toList()[i];
      }
    }
    return TaskType.oneoff;
  }

  factory Task.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final name = data['name'];
    final important = data['important'];
    final TaskRecurrence recurrence = Task.recurrenceFromString(data['recurrence']);
    final TaskType type = Task.typeFromString(data['recurrence']);
    

    return Task(
      id: documentId,
      name: name,
      important: important,
      type: type,
      recurrence: recurrence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'important': important,
      'recurrence': taskRecurrenceStrings[recurrence],
      'type': taskTypeStrings[type],
    };
  }
}
