import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timer_team/models/day_timer_object.dart';
import 'package:timer_team/models/user_object.dart';
import 'package:timer_team/models/week_timer_object.dart';

import 'fire_storage.dart';

class FireDatabase {
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  Future<String> addUser({
    required UserObject nameObject,
  }) async {
    final newChildRef =
        ref.child("users").push(); // generates a new child with a unique ID
    await newChildRef.set({
      'firstname': nameObject.firstName,
      'lastname': nameObject.lastName,
    });
    return Future.value(newChildRef.key);
  }

  Future<List<UserObject>> getAllUsers() async {
    List<UserObject> users = [];
    Map? usersFirebase;
    DataSnapshot refUsersGet = await ref.child("users").get();
    usersFirebase = refUsersGet.value as Map?;
    print(usersFirebase);
    if (usersFirebase != null) {
      usersFirebase = Map.fromEntries(usersFirebase.entries.toList()
        ..sort((e1, e2) => e1.key.compareTo(e2.key)));
      usersFirebase.forEach((key, value) {
        List<WeekTimerObject> listWeekTimerObject = [];
        (value["week"] as Map?)?.forEach((keyWeek, valueWeek) {
          List<DayTimerObject> listDayTimerObject = [];
          (valueWeek["day"] as Map?)?.forEach((keyDay, valueDay) {
            listDayTimerObject.add(DayTimerObject(
                id: keyDay, timerDurationDay: valueDay['timerDurationDay']));
          });
          listWeekTimerObject.add(WeekTimerObject(
              id: keyWeek,
              timerDurationWeek: valueWeek['timerDurationWeek'] ?? 0,
              isFourDaysWeek: valueWeek['isFourDaysWeek'] ?? true,
              dayTimerObject: listDayTimerObject));
        });

        users.add(
          UserObject(
            id: key,
            firstName: value["firstname"],
            lastName: value["lastname"],
            weekTimerObject: listWeekTimerObject,
          ),
        );
      });
    }
    return Future.value(users);
  }

  Future<UserObject> getUser({required UserObject user}) async {
    Map? userFirebase;
    DataSnapshot refUsersGet = await ref.child("users/${user.id}").get();
    userFirebase = refUsersGet.value as Map?;

    if (userFirebase != null) {
      List<WeekTimerObject> listWeekTimerObject = [];
      (userFirebase["week"] as Map?)?.forEach((keyWeek, valueWeek) {
        List<DayTimerObject> listDayTimerObject = [];
        (valueWeek["day"] as Map?)?.forEach((keyDay, valueDay) {
          listDayTimerObject.add(DayTimerObject(
              id: keyDay, timerDurationDay: valueDay['timerDurationDay']));
        });
        listWeekTimerObject.add(WeekTimerObject(
            id: keyWeek,
            timerDurationWeek: valueWeek['timerDurationWeek'] ?? 0,
            isFourDaysWeek: valueWeek['isFourDaysWeek'] ?? true,
            dayTimerObject: listDayTimerObject));
      });

      String? imageLink = await FireStorage().getImageUser(idUser: user.id);

      user = UserObject(
        id: user.id,
        firstName: userFirebase["firstname"],
        lastName: userFirebase["lastname"],
        weekTimerObject: listWeekTimerObject,
        linkImage: imageLink,
      );
      return Future.value(user);
    } else {
      return Future.value(user);
    }
  }

  int _weeksBetween(DateTime from, DateTime to) {
    from = DateTime.utc(from.year, from.month, from.day);
    to = DateTime.utc(to.year, to.month, to.day);
    return (to.difference(from).inDays / 7).ceil();
  }

  Future<List<UserObject>> addDateTimer(
      {required UserObject nameObject, required int timerDay}) {
    DateTime dateTime = DateTime.now();

    /**
     * Week add timer
     */
    final now = DateTime.now();
    final firstJan = DateTime(now.year, 1, 1);
    final weekNumber = _weeksBetween(firstJan, now);
    final weekKey = '${weekNumber}_${now.year}';
    final weekChild = ref.child(
        "users/${nameObject.id}/week/$weekKey"); // generates a new child with a unique ID
    Map? weekFirebase = {};
    int timerWeek = timerDay;
    weekChild.get().then((value) => {
          weekFirebase = value.value as Map?,
          if (weekFirebase != null)
            {
              if (weekFirebase!['timerDurationWeek'] != null)
                {
                  timerWeek = weekFirebase!['timerDurationWeek'] + timerDay,
                },
              if (weekFirebase!['isFourDaysWeek'] == null)
                {
                  weekChild.update({
                    'isFourDaysWeek': true,
                  }),
                },
            }
          else
            {
              weekChild.update({
                'isFourDaysWeek': true,
              }),
            },
          print(timerWeek),
          weekChild.update({
            'timerDurationWeek': timerWeek,
          }),
        });

    /**
     * Day add timer
     */
    String keyDateDay = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
    final dayChild = ref.child(
        "users/${nameObject.id}/week/$weekKey/day/$keyDateDay"); // generates a new child with a unique ID
    Map? dayFirebase = {};
    int timerDayFirebase = timerDay;
    dayChild.get().then((value) => {
          dayFirebase = value.value as Map?,
          if (dayFirebase != null && dayFirebase!['timerDurationDay'] != null)
            {
              timerDayFirebase = dayFirebase!['timerDurationDay'] + timerDay,
            },
          dayChild.update({
            'timerDurationDay': timerDayFirebase,
          }),
        });

    return getAllUsers();
  }

  bool verifIfUserSaveTimerToday({required UserObject nameObject}) {
    DateTime dateTime = DateTime.now();
    String keyDateDay = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
    final firstJan = DateTime(dateTime.year, 1, 1);
    final weekNumber = _weeksBetween(firstJan, dateTime);
    final weekKey = '${weekNumber}_${dateTime.year}';

    bool verif = false;

    if (nameObject.weekTimerObject.isNotEmpty) {
      WeekTimerObject? weekTimerObject = nameObject.weekTimerObject
          .firstWhereOrNull((element) => element.id == weekKey);
      if (weekTimerObject != null &&
          weekTimerObject.dayTimerObject.isNotEmpty) {
        weekTimerObject.dayTimerObject
            .firstWhereOrNull((element) => element.id == keyDateDay);
        if (weekTimerObject.dayTimerObject
                .firstWhereOrNull((element) => element.id == keyDateDay) !=
            null) {
          verif = true;
        }
      }
    }

    return verif;
  }

  DayTimerObject? getDayTimerObjectOfUser(UserObject user) {
    DayTimerObject? dayTimerObject;
    DateTime dateTime = DateTime.now();
    String keyDateDay = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
    final firstJan = DateTime(dateTime.year, 1, 1);
    final weekNumber = _weeksBetween(firstJan, dateTime);
    final weekKey = '${weekNumber}_${dateTime.year}';

    if (user.weekTimerObject.isNotEmpty) {
      WeekTimerObject? weekTimerObject = user.weekTimerObject
          .firstWhereOrNull((element) => element.id == weekKey);
      if (weekTimerObject != null &&
          weekTimerObject.dayTimerObject.isNotEmpty) {
        weekTimerObject.dayTimerObject
            .firstWhereOrNull((element) => element.id == keyDateDay);
        if (weekTimerObject.dayTimerObject
                .firstWhereOrNull((element) => element.id == keyDateDay) !=
            null) {
          dayTimerObject = weekTimerObject.dayTimerObject
              .firstWhere((element) => element.id == keyDateDay);
        }
      }
    }

    return dayTimerObject;
  }

  Future<UserObject> switchWeekTypeOfUser(
      {required UserObject user,
      required DateTime dateTime,
      required bool isFourDaysWeek}) async {
    /**
     * Week add timer
     */

    final firstJan = DateTime(dateTime.year, 1, 1);
    final weekNumber = _weeksBetween(firstJan, dateTime);
    final weekKey = '${weekNumber}_${dateTime.year}';
    final weekChild = ref.child(
        "users/${user.id}/week/$weekKey"); // generates a new child with a unique ID
    Map? weekFirebase = {};
    weekChild.get().then((value) => {
          weekFirebase = value.value as Map?,
          if (weekFirebase != null)
            {
              if (weekFirebase!['isFourDaysWeek'] == null)
                {
                  weekChild.update({
                    'isFourDaysWeek': !isFourDaysWeek,
                  }),
                }
              else
                {
                  weekChild.update({
                    'isFourDaysWeek': !isFourDaysWeek,
                  }),
                },
            }
          else
            {
              weekChild.update({
                'isFourDaysWeek': !isFourDaysWeek,
              }),
            },
        });
    return getUser(user: user);
  }

  WeekTimerObject? getWeekOfUser(
      {required UserObject user, required DateTime dateTime}) {
    WeekTimerObject? weekTimerObjectFinal;
    final firstJan = DateTime(dateTime.year, 1, 1);
    final weekNumber = _weeksBetween(firstJan, dateTime);
    final weekKey = '${weekNumber}_${dateTime.year}';

    if (user.weekTimerObject.isNotEmpty) {
      return user.weekTimerObject
          .firstWhereOrNull((element) => element.id == weekKey);
    }
    return weekTimerObjectFinal;
  }
}
