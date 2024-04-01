import 'package:flutter/cupertino.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

/*

S E T U P

*/

// I N I T I A L I Z E - D A T A B A S E

  static Future<void> initiliaze() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

// SAVE FIRST DATE OF APP STARTUP (FOR HEATMAP)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

// GET FIRST DATE OF APP STARTUP (FOR HEATMAP)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

/*

C R U D - O P E R A T I O N S

 */

// LIST OF HABITS
  final List<Habit> currentHabits = [];

// CREATE - ADD NEW HABIT
  Future<void> addHabit(String habitName) async {
    //   create new habit
    final newHabit = Habit()..name = habitName;

    // save to db
    await isar.writeTxn(() => isar.habits.put(newHabit));

    //   re-read from db
    readHabits();
  }

// READ - READ SAVED HABITS FROM DB
  Future<void> readHabits() async {
    //   fetch al habits from db
    List<Habit> fetchHabits = await isar.habits.where().findAll();

    //   give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchHabits);

    //   update UI
    notifyListeners();
  }

// UPDATE - CHECK HABIT ON ADN OFF
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
//     find the specific habit
    final habit = await isar.habits.get(id);

// update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        //   if habit is completed -> add the current date to the completedDays list
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          //   today
          final today = DateTime.now();

          //   add the current date if it's not already in the list
          habit.completedDays.add(DateTime(today.year, today.month, today.day));
        }
        // if habit is NOT completed -> remove the current date from the list
        else {
          //   remove the current date if the habit is marked as not completed
          habit.completedDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        //   save the updated habits back to the db
        await isar.habits.put(habit);
      });
    }
    //   re-read form db
    readHabits();
  }

// UPDATE - EDIT HABIT NAME
  Future<void> updateHabitName(int id, String newName) async {
    //   find the specific habit
    final habit = await isar.habits.get(id);

    //   update habit name
    if (habit != null) {
      //   update name
      await isar.writeTxn(() async {
        habit.name = newName;
        //   save updated habit back to the db
        await isar.habits.put(habit);
      });
    }
    //   re-read from db
    readHabits();
  }

// DELETE - DELETE HABIT
  Future<void> deleteHabit(int id) async {
//     perform delete
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
// re-read from db
    readHabits();
  }
}
