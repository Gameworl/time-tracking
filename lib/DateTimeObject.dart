class DateTimeObject {
  int? id;
  int nameId;
  int date;
  int time;

  DateTimeObject({
    this.id,
    required this.nameId,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'nameId': nameId, 'date': date, 'time': time};
  }

  static DateTimeObject fromMap(Map<String, dynamic> map) {
    return DateTimeObject(
      id: map['id'],
      nameId: map['nameId'],
      date: map['date'],
      time: map['time'],
    );
  }
}
