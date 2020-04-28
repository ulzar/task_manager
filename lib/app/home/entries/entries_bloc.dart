import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:task_manager/app/home/entries/entry_task.dart';
import 'package:task_manager/app/home/models/entry.dart';
import 'package:task_manager/app/home/models/task.dart';
import 'package:task_manager/common_widgets/platform_exception_alert_dialog.dart';
import 'package:task_manager/services/database.dart';
import 'package:task_manager/services/day_controller.dart';

class EntriesBloc {
  EntriesBloc({@required this.database, @required this.dayController}) {
    assert(dayController != null);
    assert(database != null);
    print("setting up task stream");
    // _tasksStream = new Observable(database.tasksStream()).startWith(new List<Task>());
    // _entriesStream = new Observable(database.entriesStream()).startWith(new List<Entry>());
    final taskStream = new BehaviorSubject<List<Task>>();
    taskStream.add(new List<Task>());
    taskStream.addStream(database.tasksStream());
    _tasksStream = taskStream;

    final entryStream = new BehaviorSubject<List<Entry>>();
    entryStream.add(new List<Entry>());
    entryStream.addStream(database.entriesStream());
    _entriesStream = entryStream;

    // Observable().
    // _entriesStream = new BehaviorSubject<List<Entry>>();
    // _entriesStream.add(new List<Entry>());
    // _entriesStream.addStream(database.entriesStream());

    print("task stream setup");
  }
  final Database database;
  final DayController dayController;

  Observable<List<Task>> _tasksStream;
  Observable<List<Entry>> _entriesStream;

  Observable<List<EntryTask>> get _allEntriesStream =>
      Observable.combineLatest3(
        _entriesStream,
        _tasksStream,
        dayController.stream,
        _entriesTasksDayCombiner,
      );

  static List<EntryTask> _entriesTasksDayCombiner(
    List<Entry> entries,
    List<Task> tasks,
    DateTime selectedDay,
  ) {
    print("*****    _entriesTasksDayCombiner: ${entries.length} entries, ${tasks.length} tasks, selectedDay $selectedDay");
    // entries.forEach((element) {
    //   print('Entry: ${element.id}, Creation: ${element.creationDate}, ');
    // });
    // print("entries $entries");
    // print("tasks $tasks");
    // print("selectedDay $selectedDay");
    // Keep only the entry created on the selected day
    // entries
    //     .removeWhere((element) => element.creationDate.day != selectedDay.day);
    List<Entry> filteredEntries = entries.where((element) => element.creationDate.day == selectedDay.day).toList();
    // print('Got ${entries.length} entries');
    return filteredEntries.map((entry) {
      final task = tasks.firstWhere(
        (job) => job.id == entry.taskId,
        orElse: null,
      );
      return EntryTask(entry, task);
    }).toList();
  }

  Observable<List<EntryTask>> get allEntriesStreamOrdered =>
      _allEntriesStream.map((List<EntryTask> entryTasks) {
        entryTasks.sort((a, b) {
          // Sort by Important
          if (!a.entry.important && b.entry.important) {
            return 1;
          }
          return -1;
        });
        entryTasks.sort((a, b) {
          // Sort by Completed
          if (a.entry.completed && !b.entry.completed) {
            return 1;
          }
          return -1;
        });
        return entryTasks;
      });

  Observable<List<Task>> get availableUnselectedTasks =>
      Observable.combineLatest3(
        _entriesStream,
        _tasksStream,
        dayController.stream,
        _filterByAvailableTasks,
      );

  static List<Task> _filterByAvailableTasks(
    List<Entry> entries,
    List<Task> tasks,
    DateTime selectedDay,
  ) {
    print("_filterByAvailableTasks");

    List<Entry> filteredEntries = entries.where((element) => element.creationDate.day == selectedDay.day).toList();
    // Keep only the entry of the day
    // entries
    //     .removeWhere((element) => element.creationDate.day != selectedDay.day);
    // Remove task which already have been assigned by an entry
    List<Task> availableTaskOfTheDay = new List<Task>();

    tasks.forEach((task) {
      filteredEntries.firstWhere(
        (entry) => task.id == entry.taskId,
        orElse: () {
          availableTaskOfTheDay.add(task);
          return null;
        }
      );
    });
    return availableTaskOfTheDay.toList();
  }

  Future<void> toggleEntryComplete(
      BuildContext context, EntryTask entryTask) async {
    print('_toggleEntryComplete');
    final entry = entryTask.entry;
    entry.completed = !entry.completed;
    await _setEntryAndDismiss(context, entry);
  }

  Future<void> toggleEntryImportant(
      BuildContext context, EntryTask entryTask) async {
    print('_toggleEntryImportant');
    final entry = entryTask.entry;
    entry.important = !entry.important;
    await _setEntryAndDismiss(context, entry);
  }

  Future<void> _setEntryAndDismiss(BuildContext context, Entry entry) async {
    try {
      await database.setEntry(entry);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  Future<void> deleteEntry(BuildContext context, Entry entry) async {
    try {
      await database.deleteEntry(entry);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  // /// Output stream
  // Stream<List<EntriesListTileModel>> get entriesTileModelStream =>
  //     _allEntriesStreamOrdered.map(_createModels);

//   static List<EntriesListTileModel> _createModels(List<Entry> allEntries) {
//     int completedEntries = 0;
//     allEntries.forEach((entry) {
//       if (entry.completed) {
//         completedEntries++;
//       }
//      });

// return <EntriesListTileModel>[
//       EntriesListTileModel(
//         leadingText: 'All Entries',
//         middleText: Format.currency(totalPay),
//         trailingText: Format.hours(totalDuration),
//       ),
//       for (DailyJobsDetails dailyJobsDetails in allDailyJobsDetails) ...[
//         EntriesListTileModel(
//           isHeader: true,
//           leadingText: Format.date(dailyJobsDetails.date),
//           middleText: Format.currency(dailyJobsDetails.pay),
//           trailingText: Format.hours(dailyJobsDetails.duration),
//         ),
//         for (JobDetails taskDuration in dailyJobsDetails.tasksDetails)
//           EntriesListTileModel(
//             leadingText: taskDuration.name,
//             middleText: Format.currency(taskDuration.pay),
//             trailingText: Format.hours(taskDuration.durationInHours),
//           ),
//       ]
//     ];
//   }

  // /// combine List<Job>, List<Entry> into List<EntryJob>
  // Stream<List<EntryJob>> get _allEntriesStream => Observable.combineLatest2(
  //       database.entriesStream(),
  //       database.tasksStream(),
  //       _entriesJobsCombiner,
  //     );

  // static List<EntryJob> _entriesJobsCombiner(
  //     List<Entry> entries, List<Job> tasks) {
  //   return entries.map((entry) {
  //     final task = tasks.firstWhere((task) => task.id == entry.taskId);
  //     return EntryJob(entry, task);
  //   }).toList();
  // }

  // /// Output stream
  // Stream<List<EntriesListTileModel>> get entriesTileModelStream =>
  //     _allEntriesStream.map(_createModels);

  // static List<EntriesListTileModel> _createModels(List<EntryJob> allEntries) {
  //   final allDailyJobsDetails = DailyJobsDetails.all(allEntries);

  //   // total duration across all tasks
  //   final totalDuration = allDailyJobsDetails
  //       .map((dateJobsDuration) => dateJobsDuration.duration)
  //       .reduce((value, element) => value + element);

  //   // total pay across all tasks
  //   final totalPay = allDailyJobsDetails
  //       .map((dateJobsDuration) => dateJobsDuration.pay)
  //       .reduce((value, element) => value + element);

  //   return <EntriesListTileModel>[
  //     EntriesListTileModel(
  //       leadingText: 'All Entries',
  //       middleText: Format.currency(totalPay),
  //       trailingText: Format.hours(totalDuration),
  //     ),
  //     for (DailyJobsDetails dailyJobsDetails in allDailyJobsDetails) ...[
  //       EntriesListTileModel(
  //         isHeader: true,
  //         leadingText: Format.date(dailyJobsDetails.date),
  //         middleText: Format.currency(dailyJobsDetails.pay),
  //         trailingText: Format.hours(dailyJobsDetails.duration),
  //       ),
  //       for (JobDetails taskDuration in dailyJobsDetails.tasksDetails)
  //         EntriesListTileModel(
  //           leadingText: taskDuration.name,
  //           middleText: Format.currency(taskDuration.pay),
  //           trailingText: Format.hours(taskDuration.durationInHours),
  //         ),
  //     ]
  //   ];
  // }
}
