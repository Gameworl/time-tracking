import 'dart:convert';

import 'package:timer_team/models/week_timer_object.dart';

class UserObject {
  String id;
  String firstName;
  String lastName;
  String? linkImage;
  List<WeekTimerObject> weekTimerObject;

  UserObject(
      {required this.id,
      required this.firstName,
      required this.lastName,
      this.linkImage,
      required this.weekTimerObject});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'linkImage': linkImage ?? "",
      'weekTimerObject': weekTimerObject.toString(),
    };
  }

  static UserObject fromMap(Map<String, dynamic> map) {
    return UserObject(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      weekTimerObject: map['weekTimerObject'],
      linkImage: map['linkImage'] ?? "",
    );
  }

  @override
  String toString() {
    // TODO: implement toString

    return jsonEncode(UserObject(
            id: id,
            firstName: firstName,
            lastName: lastName,
            linkImage: linkImage ?? "",
            weekTimerObject: weekTimerObject)
        .toMap());
  }
}
