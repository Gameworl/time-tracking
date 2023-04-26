import 'dart:core';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:timer_team/models/user_object.dart';

import 'fire_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<UserObject> users = [];
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  List<StopWatchTimer> listTimer = [];
  List<bool> timerStart = [];
  List<bool> dayOver = [];
  List<int> timervalue = [];
  List<int> globaltime = [];
  final now = DateTime.now();

  @override
  void initState() {
    getAllName();
    super.initState();
  }

  getAllName() {
    FireDatabase()
        .getAllUsers()
        .then((value) => {refreshUsers(listUsers: value)});
  }

  refreshUsers({required List<UserObject> listUsers}) {
    int nb;
    if (mounted) {
      setState(() {
        users = listUsers;
        nb = users.length - listTimer.length;
        if (users.length > listTimer.length) {
          for (var i = 0; i <= nb; i++) {
            listTimer.add(StopWatchTimer());
            timerStart.add(false);
            timervalue.add(0);
            dayOver.add(false);
          }
        }
      });
    } else {
      users = listUsers;
      nb = users.length - listTimer.length;
      if (users.length > listTimer.length) {
        for (var i = 0; i <= nb; i++) {
          listTimer.add(StopWatchTimer());
          timerStart.add(false);
          timervalue.add(0);
          dayOver.add(false);
        }
      }
    }
  }

  popUpAddPerson() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter your name'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'First name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _firstName = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Last name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _lastName = value!;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Leave'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Validate'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    FireDatabase()
                        .addUser(
                            nameObject: UserObject(
                                firstName: _firstName,
                                lastName: _lastName,
                                id: '',
                                monthTimerObject: []))
                        .then((value) => refreshUsers(listUsers: value));
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 30, top: 50, right: 30, bottom: 50),
        height: MediaQuery.of(context).size.height - 100,
        child: Flex(
          direction: Axis.vertical,
          children: [
            OutlinedButton(
              onPressed: () => popUpAddPerson(),
              child: const Text("Ajouter une personne"),
            ),
            Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final nameObject = users[index];
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                            '${nameObject.firstName} ${nameObject.lastName.toString()[0].toUpperCase()} '),
                        OutlinedButton(
                            onPressed: () {
                              timerStart[index]
                                  ? listTimer[index].onStopTimer()
                                  : listTimer[index].onStartTimer();
                              setState(() {
                                timerStart[index] = !timerStart[index];
                              });
                            },
                            child: Text(timerStart[index] ? "pause" : "Start")),
                        StreamBuilder<int>(
                          stream: listTimer[index].rawTime,
                          initialData: listTimer[index].rawTime.value,
                          builder: (context, snap) {
                            final value = snap.data!;
                            timervalue[index] = snap.data!;
                            final displayTime = StopWatchTimer.getDisplayTime(
                                value,
                                hours: true,
                                minute: true,
                                second: true,
                                milliSecond: false);
                            return Text(
                              displayTime,
                              style: const TextStyle(fontSize: 30),
                            );
                          },
                        ),
                        verifDayTimer(nameObject: nameObject)
                            ? OutlinedButton(
                                onPressed: () => {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey,
                                ),
                                child: const Text("Fin de journée"))
                            : OutlinedButton(
                                onPressed: () => {
                                      timerStart[index]
                                          ? listTimer[index].onStopTimer()
                                          : listTimer[index].onStartTimer(),
                                      setState(() {
                                        timerStart[index] = !timerStart[index];
                                      }),
                                      FireDatabase().addDateTimer(
                                        nameObject: nameObject,
                                        timerDay: timervalue[index].toInt(),
                                      ),
                                    },
                                child: const Text("Fin de journée")),
                      ],
                    ),
                  );
                },
              ),
            ),
            Column(
              children: [
                const Text("WeekTime"),
                users.isNotEmpty && false
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        child: ListView.builder(
                          itemCount: users.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final nameObject = users[index];
                            return Container(
                              height: 50,
                              width: 200,
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                        '${nameObject.firstName} ${nameObject.lastName.toString()[0].toUpperCase()} => ${StopWatchTimer.getDisplayTimeHours(globaltime[index])} - ${StopWatchTimer.getDisplayTimeMinute(globaltime[index], hours: true)}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool verifDayTimer({required UserObject nameObject}) {
    return FireDatabase().verifIfUserSaveTimerToday(nameObject: nameObject);
  }
}
