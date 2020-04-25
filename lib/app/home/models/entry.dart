import 'package:flutter/foundation.dart';

class Entry {
  Entry({
    @required this.id,
    @required this.creationDate,
    @required this.taskId,
    @required this.important,
    @required this.completed,
    @required this.completionDetail,
  });

  String id;
  String taskId;
  DateTime creationDate;
  String completionDetail;
  bool completed;
  bool important;


  factory Entry.fromMap(Map<dynamic, dynamic> value, String id) { 
    final int creationMilliseconds = value['creation'];
    return Entry(
      id: id,
      taskId: value['taskId'],
      creationDate: DateTime.fromMicrosecondsSinceEpoch(creationMilliseconds),
      completionDetail: value['completionDetail'],
      completed: value['completed'],
      important: value['important'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'taskId': taskId,
      'completionDetail': completionDetail,
      'completed': completed,
      'important': important,
      'creation': creationDate.millisecondsSinceEpoch,
    };
  }
}
