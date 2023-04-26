import 'month_timer_object.dart';

class UserObject {
  String id;
  String firstName;
  String lastName;
  List<MonthTimerObject> monthTimerObject;

  UserObject(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.monthTimerObject});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'monthTimerObject': monthTimerObject,
    };
  }

  static UserObject fromMap(Map<String, dynamic> map) {
    return UserObject(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      monthTimerObject: map['monthTimerObject'],
    );
  }
}
