import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../util/habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // read exisiting habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  // text controller
  final TextEditingController textController = TextEditingController();

  // create new habit
  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: "Create a new habit",
                ),
              ),
              actions: [
                //   save button
                MaterialButton(
                  onPressed: () {
                    //   get the new habit name
                    String newHabitName = textController.text;

                    //   save to db
                    context.read<HabitDatabase>().addHabit(newHabitName);

                    //   pop box
                    Navigator.pop(context);

                    //   clear controller
                    textController.clear();
                  },
                  child: const Text('Save'),
                  color: Colors.greenAccent,
                ),

                //   cancel button
                MaterialButton(
                  onPressed: () {
                    //   pop box
                    Navigator.pop(context);

                    //   clear controller
                    textController.clear();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.redAccent,
                )
              ],
            ));
  }

  // check habit on and off
  void checkHabitOnOff(bool? value, Habit habit) {
    //   update habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  // edit habit
  void editHabitBox(Habit habit) {
    //   set the controller's text to the habit's current name
    textController.text = habit.name;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                //   save button
                MaterialButton(
                  onPressed: () {
                    //   get the new habit name
                    String newHabitName = textController.text;

                    //   save to db
                    context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName);

                    //   pop box
                    Navigator.pop(context);

                    //   clear controller
                    textController.clear();
                  },
                  child: const Text('Save'),
                  color: Colors.greenAccent,
                ),

                //   cancel button
                MaterialButton(
                  onPressed: () {
                    //   pop box
                    Navigator.pop(context);

                    //   clear controller
                    textController.clear();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.redAccent,
                )
              ],
            ));
  }

  // delete habit
  void deleteHabitBox(Habit habit) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Are you sure to delete this habit?"),
              actions: [
                //   delete button
                MaterialButton(
                  onPressed: () {
                    //   save to db
                    context.read<HabitDatabase>().deleteHabit(habit.id);

                    //   pop box
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.redAccent,
                ),

                //   cancel button
                MaterialButton(
                  onPressed: () {
                    //   pop box
                    Navigator.pop(context);

                    //   clear controller
                    textController.clear();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black87),
                  ),
                  color: Colors.white,
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: _buildHabitList(),
    );
  }

  // build habit list
  Widget _buildHabitList() {
    //   habit db
    final habitDatabase = context.watch<HabitDatabase>();

    //   current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //   return list of habits UI
    return ListView.builder(
        itemCount: currentHabits.length,
        itemBuilder: (context, index) {
          //   get each individual habit
          final habit = currentHabits[index];

          //   check if the habit is completed today
          bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

          //   return habit tile UI
          return MyHabitTile(
            text: habit.name,
            isCompleted: isCompletedToday,
            onChanged: (value) => checkHabitOnOff(value, habit),
            editHabit: (context) => editHabitBox(habit),
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        });
  }
}
