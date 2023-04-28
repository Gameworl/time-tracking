import 'dart:convert';

class DayTimerObject {
  String id;
  int timerDurationDay;

  DayTimerObject({required this.id, required this.timerDurationDay});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timerDurationDay': timerDurationDay,
    };
  }

  static DayTimerObject fromMap(Map<String, dynamic> map) {
    return DayTimerObject(
      id: map['id'],
      timerDurationDay: map['timerDurationDay'],
    );
  }

  @override
  String toString() {
    // TODO: implement toString

    return jsonEncode(
        DayTimerObject(id: id, timerDurationDay: timerDurationDay).toMap());
  }
}
