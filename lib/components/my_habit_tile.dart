import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final String text;
  final bool isCompleted;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext?)? editHabit;
  final void Function(BuildContext?)? deleteHabit;

  const MyHabitTile(
      {super.key,
      required this.text,
      required this.isCompleted,
      required this.onChanged,
      required this.editHabit,
      required this.deleteHabit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            //   edit option
            SlidableAction(
              onPressed: editHabit,
              backgroundColor: Colors.grey.shade800,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(8),
            ),

            //   delete option
            SlidableAction(
              onPressed: deleteHabit,
              backgroundColor: Colors.redAccent,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(8),
            )
          ],
        ),
        child: GestureDetector(
          onTap: () {
            if (onChanged != null) {
              //   toggle completion status
              onChanged!(!isCompleted);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                text,
                style: TextStyle(fontSize: 20, color: isCompleted ? Colors.white : Colors.black87),
              ),
              leading: Checkbox(
                activeColor: Colors.green,
                value: isCompleted,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
