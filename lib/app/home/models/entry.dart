import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Entry {
  Entry({
    @required this.id,
    @required this.creationDate,
    @required this.taskId,
    @required this.important,
     this.completed = false,
    this.completionDetail = '',
  });

  String id;
  String taskId;
  DateTime creationDate;
  String completionDetail;
  bool completed;
  bool important;

  static String creationDatetimeFormat = 'yyyy-MM-dd';

  static String creationDatetimeToString(DateTime input) {
    return DateFormat(creationDatetimeFormat).format(input);
  }

  static DateTime parseCreationDateTimeString(String input) {
    return DateFormat(creationDatetimeFormat).parse(input);
  }

  factory Entry.fromMap(Map<dynamic, dynamic> value, String id) {
    return Entry(
      id: id,
      taskId: value['taskId'],
      creationDate: parseCreationDateTimeString(value['creation']),
      completionDetail: value['completionDetail'],
      completed: value['completed'],
      important: value['important'],
    );
  }

  Map<String, dynamic> toMap() {
    final creationStr = creationDatetimeToString(creationDate);
    return <String, dynamic>{
      'taskId': taskId,
      'completionDetail': completionDetail,
      'completed': completed,
      'important': important,
      'creation': creationStr,
    };
  }
}
