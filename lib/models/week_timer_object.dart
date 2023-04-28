import 'dart:convert';

import 'package:timer_team/models/day_timer_object.dart';

class WeekTimerObject {
  String id;
  int timerDurationWeek;
  bool isFourDaysWeek;
  List<DayTimerObject> dayTimerObject;

  WeekTimerObject(
      {required this.id,
      required this.timerDurationWeek,
      required this.isFourDaysWeek,
      required this.dayTimerObject});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timerDurationWeek': timerDurationWeek,
      'isFourDaysWeek': isFourDaysWeek,
      'dayTimerObject': dayTimerObject.toString(),
    };
  }

  static WeekTimerObject fromMap(Map<String, dynamic> map) {
    return WeekTimerObject(
      id: map['id'],
      timerDurationWeek: map['timerDurationWeek'],
      isFourDaysWeek: map['isFourDaysWeek'],
      dayTimerObject: map['dayTimerObject'],
    );
  }

  @override
  String toString() {
    // TODO: implement toString

    return jsonEncode(WeekTimerObject(
            id: id,
            timerDurationWeek: timerDurationWeek,
            isFourDaysWeek: isFourDaysWeek,
            dayTimerObject: dayTimerObject)
        .toMap());
  }
}
