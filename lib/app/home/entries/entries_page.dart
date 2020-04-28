import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/app/home/entries/entries_bloc.dart';
import 'package:task_manager/app/home/entries/entry_task.dart';
import 'package:task_manager/app/home/entries/entries_list_tile.dart';
import 'package:task_manager/app/home/tasks/task_picker_page.dart';
import 'package:task_manager/app/home/tasks/list_items_builder.dart';
import 'package:task_manager/services/database.dart';
import 'package:task_manager/services/day_controller.dart';

class EntriesPage extends StatelessWidget {
  const EntriesPage({Key key, @required this.dayController}) : super(key: key);
  final DayController dayController;
  static Widget create(BuildContext context) {
    final database = Provider.of<Database>(context);
    final dayController = Provider.of<DayController>(context);
    return Provider<EntriesBloc>(
      create: (_) =>
          EntriesBloc(database: database, dayController: dayController),
      child: EntriesPage(dayController: dayController),
    );
  }

  Future<void> _selectCalendarDay(BuildContext context) async {
    final DateTime currentDay = dayController.currentDay;
    final DateTime today = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: currentDay,
      firstDate: today.add(-new Duration(days: DayController.furthestDayInPast)), 
      lastDate: today.add(new Duration(days: DayController.furthestDayInFuture)),
    );
    if (picked != null) {
      // Add the new day 
      dayController.selectSpecificDay(picked);
    }
  }

   Widget _buildDayPicker(BuildContext context) {
     return StreamBuilder<DateTime>(
       initialData: new DateTime.now(),
        stream: dayController.stream,
        builder: (context, snapshot) {
            DateTime currentDay = snapshot.data;
            return Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                ),
                onPressed: dayController.canSelectPreviousDay(currentDay) ? () => dayController.selectPreviousDay(currentDay) : null,
              ),
              Expanded(
                child: Text(
                  DayController.prettyPrint(currentDay),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                ),
                onPressed: dayController.canSelectNextDay(currentDay) ? () => dayController.selectNextDay(currentDay) : null,
              ),
            ],
          );
        }
    );
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entries'),
        elevation: 2.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _selectCalendarDay(context),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () => TaskPickerPage.show(
              context: context,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildDayPicker(context),
          SizedBox(
            height: 12.0,
          ),
          Expanded(
            child: _buildContents(context),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final bloc = Provider.of<EntriesBloc>(context);
    return StreamBuilder<List<EntryTask>>(
      stream: bloc.allEntriesStreamOrdered,
      builder: (context, snapshot) {
        return ListItemsBuilder<EntryTask>(
          snapshot: snapshot,
          itemBuilder: (context, entryTask) => Dismissible(
            background: Container(color: Colors.red),
            key: Key('daily-entry-${entryTask.entry.id}'),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) =>
                bloc.deleteEntry(context, entryTask.entry),
            child: EntryListTile(
              entry: entryTask.entry,
              task: entryTask.task,
              onTap: () => bloc.toggleEntryImportant(context, entryTask),
              onLongPress: () => bloc.toggleEntryComplete(context, entryTask),
            ),
          ),
        );
      },
    );
  }
}
