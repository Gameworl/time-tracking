import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timer_team/models/day_timer_object.dart';
import 'package:timer_team/models/month_timer_object.dart';
import 'package:timer_team/models/user_object.dart';
import 'package:timer_team/models/week_timer_object.dart';

class FireDatabase {
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  Future<List<UserObject>> addUser({
    required UserObject nameObject,
  }) {
    final newChildRef =
        ref.child("users").push(); // generates a new child with a unique ID
    newChildRef.set({
      'firstname': nameObject.firstName,
      'lastname': nameObject.lastName,
    });
    return getAllUsers();
  }

  Future<List<UserObject>> getAllUsers() async {
    List<UserObject> users = [];
    Map? usersFirebase;
    DataSnapshot refUsersGet = await ref.child("users").get();
    usersFirebase = refUsersGet.value as Map?;
    if (usersFirebase != null) {
      usersFirebase.forEach((key, value) {
        List<MonthTimerObject> listMonthTimerObject = [];
        (value["month"] as Map?)?.forEach((keyMonth, valueMonth) {
          List<WeekTimerObject> listWeekTimerObject = [];
          (valueMonth["week"] as Map?)?.forEach((keyWeek, valueWeek) {
            List<DayTimerObject> listDayTimerObject = [];
            (valueWeek["day"] as Map?)?.forEach((keyDay, valueDay) {
              listDayTimerObject.add(DayTimerObject(
                  id: keyDay, timerDurationDay: valueDay['timerDurationDay']));
            });
            listWeekTimerObject.add(WeekTimerObject(
                id: keyWeek,
                timerDurationWeek: valueWeek['timerDurationWeek'],
                isFourDaysWeek: valueWeek['isFourDaysWeek'],
                dayTimerObject: listDayTimerObject));
          });
          listMonthTimerObject.add(MonthTimerObject(
              id: keyMonth,
              timerDurationMonth: valueMonth['timerDurationMonth'],
              weekTimerObject: listWeekTimerObject));
        });

        users.add(
          UserObject(
              id: key,
              firstName: value["firstname"],
              lastName: value["lastname"],
              monthTimerObject: listMonthTimerObject),
        );
      });
    }
    return Future.value(users);
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
     * Month add timer
     */
    String keyDateMonth = '${dateTime.month}-${dateTime.year}';
    final monthChild = ref.child(
        "users/${nameObject.id}/month/$keyDateMonth"); // generates a new child with a unique ID
    Map? monthFirebase = {};
    int timerMonth = timerDay;
    monthChild.get().then((value) => {
          monthFirebase = value.value as Map?,
          if (monthFirebase != null &&
              monthFirebase!['timerDurationMonth'] != null)
            {
              timerMonth = monthFirebase!['timerDurationMonth'] + timerDay,
            },
          monthChild.update({
            'timerDurationMonth': timerMonth,
          }),
        });

    /**
     * Week add timer
     */
    final now = DateTime.now();
    final firstJan = DateTime(now.year, 1, 1);
    final weekNumber = _weeksBetween(firstJan, now);
    final weekChild = ref.child(
        "users/${nameObject.id}/month/$keyDateMonth/week/$weekNumber"); // generates a new child with a unique ID
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
          weekChild.update({
            'timerDurationWeek': timerWeek,
          }),
        });

    /**
     * Day add timer
     */
    String keyDateDay = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
    final dayChild = ref.child(
        "users/${nameObject.id}/month/$keyDateMonth/week/$weekNumber/day/$keyDateDay"); // generates a new child with a unique ID
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
    String keyDateMonth = '${dateTime.month}-${dateTime.year}';
    final firstJan = DateTime(dateTime.year, 1, 1);
    final weekNumber = _weeksBetween(firstJan, dateTime);

    bool verif = false;

    if (nameObject.monthTimerObject.isNotEmpty) {
      MonthTimerObject? monthTimerObject = nameObject.monthTimerObject
          .firstWhereOrNull((element) => element.id == keyDateMonth);
      if (monthTimerObject != null &&
          monthTimerObject.weekTimerObject.isNotEmpty) {
        WeekTimerObject? weekTimerObject = monthTimerObject.weekTimerObject
            .firstWhereOrNull((element) => element.id == weekNumber.toString());
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
    }

    return verif;
  }
}
