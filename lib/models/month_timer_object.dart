import 'package:timer_team/models/week_timer_object.dart';

class MonthTimerObject {
  String id;
  int timerDurationMonth;
  List<WeekTimerObject> weekTimerObject;

  MonthTimerObject(
      {required this.id,
      required this.timerDurationMonth,
      required this.weekTimerObject});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timerDurationMonth': timerDurationMonth,
      'weekTimerObject': weekTimerObject,
    };
  }

  static MonthTimerObject fromMap(Map<String, dynamic> map) {
    return MonthTimerObject(
      id: map['id'],
      timerDurationMonth: map['timerDurationMonth'],
      weekTimerObject: map['weekTimerObject'],
    );
  }

  MonthTimerObject fromFirebase(Map<String, dynamic> map) {
    return MonthTimerObject(
      id: map['id'],
      timerDurationMonth: map['timerDurationMonth'],
      weekTimerObject: map['weekTimerObject'],
    );
  }
}
