import 'package:flutter/material.dart';
import 'package:task_manager/app/home/task_entries/format.dart';
import 'package:task_manager/app/home/models/entry.dart';
import 'package:task_manager/app/home/models/task.dart';

class EntryListItem extends StatelessWidget {
  const EntryListItem({
    @required this.entry,
    @required this.task,
    @required this.onTap,
  });

  final Entry entry;
  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: <Widget>[
            _buildContents(context),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleEntryImportantState() {
    entry.important = !entry.important;

    // update entry in DB
  }

  Widget _buildContents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: <Widget>[
          Text(task.name, style: TextStyle(fontSize: 18.0, color: Colors.grey)),
          Expanded(child: Container()),
          IconButton(
            icon: Icon(
              Icons.star,
              color: entry.important ? Colors.yellow : Colors.white,
            ),
            onPressed: () => _toggleEntryImportantState,
          ),
        ]),
        if (entry.completionDetail.isNotEmpty)
          Text(
            entry.completionDetail,
            style: TextStyle(fontSize: 12.0),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );
  }
}

class DismissibleEntryListItem extends StatelessWidget {
  const DismissibleEntryListItem({
    this.key,
    this.entry,
    this.task,
    this.onDismissed,
    this.onTap,
  });

  final Key key;
  final Entry entry;
  final Task task;
  final VoidCallback onDismissed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: key,
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDismissed(),
      child: EntryListItem(
        entry: entry,
        task: task,
        onTap: onTap,
      ),
    );
  }
}
