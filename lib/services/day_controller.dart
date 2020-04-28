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

  static int furthestDayInPast = 60;
  static int furthestDayInFuture = 7;

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

  bool canSelectNextDay(DateTime currentDay) {
    if (currentDay == null) {
      return false;
    }
    final now = DateTime.now();
    final futureNextDay = DateTime(currentDay.year, currentDay.month, currentDay.day+1);
    final futureLimit = DateTime(now.year, now.month, now.day + furthestDayInFuture);
    print('* canSelectNextDay. futureLimit=$futureLimit & currentDay=$currentDay');
    if (futureLimit.compareTo(futureNextDay) < 0) {
      return false;
    }
    return true;
   }

   bool canSelectPreviousDay(DateTime currentDay) {
     if (currentDay == null) {
      return false;
    }
    final now = DateTime.now();
    final futurePreviousDay = DateTime(currentDay.year, currentDay.month, currentDay.day-1);
    final pastLimit = DateTime(now.year, now.month, now.day - furthestDayInPast);
    print('* canSelectPreviousDay. pastLimit=$pastLimit & currentDay=$currentDay');
    if (futurePreviousDay.compareTo(pastLimit) <= 0) {
      return false;
    }
    return true;
   }

  void selectNextDay(DateTime currentDay) {
    print('selectNextDay');
    _dayStream.add(
      currentDay.add(new Duration(days: 1)),
    );
  }

  void selectPreviousDay(DateTime currentDay) {
    print('selectPreviousDay');
    _dayStream.add(
      currentDay.add(new Duration(days: -1)),
    );
  }

  void selectSpecificDay(DateTime selectedDay) {
    _dayStream.add(
      selectedDay,
    );
  }
}
