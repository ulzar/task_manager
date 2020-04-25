import 'package:meta/meta.dart';

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

  factory Task.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final name = data['name'];
    final important = data['important'];
    final TaskType type = data['type'];
    TaskRecurrence rec = TaskRecurrence.everyDay;
    if (type == TaskType.recurring) {
      rec = data['recurrence'];
    }

    return Task(
      id: documentId,
      name: name,
      important: important,
      type: type,
      recurrence: rec,
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
