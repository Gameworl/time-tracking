import 'dart:core';

import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:timer_team/nameObject.dart';

import 'DateTimeObject.dart';
import 'database.dart';
import 'mainV2.dart';

void main() {
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
      home: const MyHomePage2(title: 'Flutter Demo Home Page'),
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
  final databaseHelper = DatabaseHelper();
  List name = [];
  List<DateTimeObject> date = [];
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
    databaseHelper.database;
    getAllName();
    super.initState();
  }

  getAllName() {
    int nb;
    databaseHelper.getAllName().then((value) => name = value).then((value) => {
          print(value),
          nb = name.length - listTimer.length,
          if (name.length > listTimer.length)
            {
              for (var i = 0; i <= nb; i++)
                {
                  listTimer.add(StopWatchTimer()),
                  timerStart.add(false),
                  timervalue.add(0),
                  dayOver.add(false)
                },
            },
          value.forEach((element) async {
            int val = await calcTimeWeek(element.id!, 1) +
                await calcTimeWeek(element.id!, 2) +
                await calcTimeWeek(element.id!, 3) +
                await calcTimeWeek(element.id!, 4) +
                await calcTimeWeek(element.id!, 5);
            globaltime.add(val);
          })
        });
  }

  calcTimeWeek(int id, int day) async {
    return Future.value(await databaseHelper.getDateTimeObjectWithDate(id,
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - day))));
  }

  getAllTimeOfName(int id) {
    return databaseHelper.getNameTimeObject(id);
  }

  getAllTime() {
    databaseHelper.getAllDatetime().then((value) => date = value);
  }

  checkIfDayOver(int id) {
    return databaseHelper.getDateTimeObject(id);
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
                    final nameObject = NameObject(
                      firstName: _firstName,
                      lastName: _lastName,
                    );
                    databaseHelper.insertName(nameObject).then((value) {
                      getAllName();
                      Navigator.pop(context);
                    });
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
                itemCount: name.length,
                itemBuilder: (context, index) {
                  final nameObject = name[index];
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
                        OutlinedButton(
                            onPressed: () async => {
                                  await checkIfDayOver(nameObject.id) == null
                                      ? {
                                          await databaseHelper
                                              .insertDatetime(DateTimeObject(
                                            nameId: nameObject.id,
                                            time: timervalue[index].toInt(),
                                            date: DateTime(now.year, now.month,
                                                    now.day)
                                                .millisecondsSinceEpoch,
                                          )),
                                          listTimer[index].onResetTimer(),
                                          setState(() {
                                            timerStart[index] =
                                                !timerStart[index];
                                          })
                                        }
                                      : {}
                                },
                            child: Text("Fin de journée")),
                      ],
                    ),
                  );
                },
              ),
            ),
            Column(
              children: [
                const Text("WeekTime"),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: ListView.builder(
                    itemCount: name.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final nameObject = name[index];
                      return Container(
                        height: 50,
                        width: 200,
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                  '${nameObject.firstName} ${nameObject.lastName.toString()[0].toUpperCase()} => ${StopWatchTimer.getDisplayTimeHours(globaltime[index])} - ${StopWatchTimer.getDisplayTimeMinute(globaltime[index], hours: true)}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
