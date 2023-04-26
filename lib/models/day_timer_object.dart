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

  DayTimerObject fromFirebase(Map<String, dynamic> map) {
    return DayTimerObject(
      id: map['id'],
      timerDurationDay: map['timerDurationDay'],
    );
  }
}
