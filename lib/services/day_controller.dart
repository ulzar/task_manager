import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class DayController {
  BehaviorSubject<DateTime> _dayStream;
  DateTime _currentDay;
  DayController() {
    _dayStream = new BehaviorSubject<DateTime>();
    // We store the current_Day at all time
    _dayStream.listen((event) {
      print("DayController - new day: $event");
      _currentDay = event;
    } );
    _dayStream.add(DateTime.now());
    // _currentDay = new BehaviorSubject<DateTime>();
  }

  static String prettyPrint(DateTime inputDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final aDate = DateTime(inputDate.year, inputDate.month, inputDate.day);
    if (aDate == today) {
      return "Today";
    } else if (aDate == yesterday) {
      return "Yesterday";
    } else if (aDate == tomorrow) {
      return "Tomorrow";
    }

    return DateFormat('EEE, MMM d').format(aDate);
  }

  Observable<DateTime> get stream => _dayStream;
  DateTime get currentDay => _currentDay;

  void selectNextDay() {
    _dayStream.add(
      _currentDay.add(new Duration(days: 1)),
    );
  }

  void selectPreviousDay() {
    _dayStream.add(
      _currentDay.add(new Duration(days: -1)),
    );
  }

  void selectSpecificDay(DateTime selectedDay) {
    _dayStream.add(
      selectedDay,
    );
  }
}
