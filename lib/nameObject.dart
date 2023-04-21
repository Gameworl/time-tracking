class NameObject {
  int? id;
  String firstName;
  String lastName;

  NameObject({this.id, required this.firstName, required this.lastName});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  static NameObject fromMap(Map<String, dynamic> map) {
    return NameObject(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
    );
  }
}
