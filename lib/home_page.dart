import 'dart:core';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timer_team/fire_storage.dart';
import 'package:timer_team/models/day_timer_object.dart';
import 'package:timer_team/models/week_timer_object.dart';

import 'fire_database.dart';
import 'models/user_object.dart';

class MyHomePage2 extends StatefulWidget {
  const MyHomePage2({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage2> createState() => _MyHomePage2State();
}

class _MyHomePage2State extends State<MyHomePage2> {
  late final ValueNotifier<List<Event>> _selectedEvent;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  List<UserObject> users = [];
  UserObject? userSelected;
  bool onUserSelected = false;
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  List<StopWatchTimer> listTimer = [];
  List<bool> timerStart = [];
  List<bool> dayOver = [];
  List<int> timervalue = [];
  List<int> globaltime = [];
  final now = DateTime.now();

  final ImagePicker _picker = ImagePicker();
  XFile? imageUser;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    getAllName();
    _selectedDay = _focusedDay;
    _selectedEvent = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  getAllName() {
    FireDatabase()
        .getAllUsers()
        .then((value) => {refreshUsers(listUsers: value)});
  }

  @override
  void dispose() {
    _selectedEvent.dispose();
    super.dispose();
  }

  int _weeksBetween(DateTime from, DateTime to) {
    from = DateTime.utc(from.year, from.month, from.day);
    to = DateTime.utc(to.year, to.month, to.day);
    return (to.difference(from).inDays / 7).ceil();
  }

  List<Event> _getEventsForDay(DateTime day) {
    List<Event> eventsForDay = [];
    // Implementation example
    String keyDateDay = '${day.day}-${day.month}-${day.year}';
    final firstJan = DateTime(day.year, 1, 1);
    final weekNumber = _weeksBetween(firstJan, day);
    final weekKey = '${weekNumber}_${day.year}';

    int dayTime = 0;
    int weekTime = 0;
    bool isFourDaysWeek = true;

    if (userSelected != null &&
        userSelected!.weekTimerObject
                .firstWhereOrNull((element) => element.id == weekKey) !=
            null) {
      WeekTimerObject weekTimerObject = userSelected!.weekTimerObject
          .firstWhere((element) => element.id == weekKey);
      weekTime = weekTimerObject.timerDurationWeek;
      '${StopWatchTimer.getDisplayTimeHours(weekTimerObject.timerDurationWeek)}:${StopWatchTimer.getDisplayTimeMinute(weekTimerObject.timerDurationWeek)}';
      isFourDaysWeek = weekTimerObject.isFourDaysWeek;
      if (weekTimerObject.dayTimerObject
              .firstWhereOrNull((element) => element.id == keyDateDay) !=
          null) {
        DayTimerObject dayTimerObject = weekTimerObject.dayTimerObject
            .firstWhere((element) => element.id == keyDateDay);
        dayTime = dayTimerObject.timerDurationDay;
        '${StopWatchTimer.getDisplayTimeHours(dayTimerObject.timerDurationDay)}:${StopWatchTimer.getDisplayTimeMinute(dayTimerObject.timerDurationDay)}';
        eventsForDay.add(Event(
            dayTime: dayTime,
            weekTime: weekTime,
            isFourDaysWeek: isFourDaysWeek));
      }
    }
    return eventsForDay;
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);
    List<Event> eventsForDay = [];
    // Implementation example
    for (var day in days) {
      String keyDateDay = '${day.day}-${day.month}-${day.year}';
      final firstJan = DateTime(day.year, 1, 1);
      final weekNumber = _weeksBetween(firstJan, day);
      final weekKey = '${weekNumber}_${day.year}';

      int dayTime = 0;
      int weekTime = 0;
      bool isFourDaysWeek = true;

      if (userSelected != null &&
          userSelected!.weekTimerObject
                  .firstWhereOrNull((element) => element.id == weekKey) !=
              null) {
        WeekTimerObject weekTimerObject = userSelected!.weekTimerObject
            .firstWhere((element) => element.id == weekKey);
        weekTime = weekTimerObject.timerDurationWeek;
        isFourDaysWeek = weekTimerObject.isFourDaysWeek;
        if (weekTimerObject.dayTimerObject
                .firstWhereOrNull((element) => element.id == keyDateDay) !=
            null) {
          DayTimerObject dayTimerObject = weekTimerObject.dayTimerObject
              .firstWhere((element) => element.id == keyDateDay);
          dayTime = dayTimerObject.timerDurationDay;
          eventsForDay.add(Event(
              dayTime: dayTime,
              weekTime: weekTime,
              isFourDaysWeek: isFourDaysWeek));
        }
      }
    }

    return eventsForDay;
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvent.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvent.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvent.value = _getEventsForDay(end);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay) || onUserSelected) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        onUserSelected = false;
        _selectedEvent.value = _getEventsForDay(selectedDay);
      });
    }
  }

  refreshUsers({required List<UserObject> listUsers}) {
    if (mounted) {
      setState(() {
        users = listUsers;
        for (var user in users) {
          StopWatchTimer stopWatchTimer = StopWatchTimer();
          int timerValue = 0;
          DayTimerObject? dayTimerObject =
              FireDatabase().getDayTimerObjectOfUser(user);
          if (dayTimerObject != null) {
            stopWatchTimer.setPresetTime(mSec: dayTimerObject.timerDurationDay);
            timerValue = dayTimerObject.timerDurationDay;
          }
          listTimer.add(stopWatchTimer);
          timerStart.add(false);
          timervalue.add(timerValue);
          dayOver.add(verifDayTimer(nameObject: user));
        }
      });
    } else {
      users = listUsers;
      for (var user in users) {
        StopWatchTimer stopWatchTimer = StopWatchTimer();
        int timerValue = 0;
        DayTimerObject? dayTimerObject =
            FireDatabase().getDayTimerObjectOfUser(user);
        if (dayTimerObject != null) {
          stopWatchTimer.setPresetTime(mSec: dayTimerObject.timerDurationDay);
          timerValue = dayTimerObject.timerDurationDay;
        }
        listTimer.add(stopWatchTimer);
        timerStart.add(false);
        timervalue.add(timerValue);
        dayOver.add(verifDayTimer(nameObject: user));
      }
    }
    refreshImageUsers(listUsers: listUsers);
  }

  refreshImageUsers({required List<UserObject> listUsers}) async {
    for (var user in listUsers) {
      String? imageLink;
      try {
        imageLink = await FireStorage().getImageUser(idUser: user.id);
      } on FirebaseException catch (e) {
        print("failed to upload to FireStorage : $e");
      }
      user.linkImage = imageLink;
    }
    setState(() => users = listUsers);
  }

  refreshUser({required UserObject user}) {
    FireDatabase().getUser(user: user).then((value) => {
          if (mounted)
            {
              setState(() => {
                    userSelected = value,
                    onUserSelected = true,
                    _onDaySelected(DateTime.now(), DateTime.now()),
                    _getEventsForDay(DateTime.now()),
                  }),
            }
          else
            {
              userSelected = value,
              onUserSelected = true,
              _onDaySelected(DateTime.now(), DateTime.now()),
              _getEventsForDay(DateTime.now()),
            },
          refreshImageUser(user: user),
        });
  }

  refreshImageUser({required UserObject user}) async {
    String? imageLink;
    try {
      imageLink = await FireStorage().getImageUser(idUser: user.id);
    } on FirebaseException catch (e) {
      print("failed to upload to FireStorage : $e");
    }
    setState(() => user.linkImage = imageLink);
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
                                weekTimerObject: []))
                        .then((value) => {
                              Navigator.pop(context),
                              setState(() => {
                                    users.add(UserObject(
                                        firstName: _firstName,
                                        lastName: _lastName,
                                        id: value,
                                        weekTimerObject: [])),
                                    listTimer.add(StopWatchTimer()),
                                    timerStart.add(false),
                                    timervalue.add(0),
                                    dayOver.add(false),
                                  }),
                            });
                  }
                },
              ),
            ],
          );
        });
  }

  popUpAddImagePerson({required UserObject userObject}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choose your mode !'),
            actions: [
              TextButton(
                child: const Text('Leave'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('With Camera'),
                onPressed: () {
                  Navigator.pop(context);
                  pickImageFromCamera().then((value) => {
                        if (value != null)
                          {
                            FireStorage()
                                .setImageUser(
                                    userObject: userObject, image: value)
                                .then((value) =>
                                    refreshImageUser(user: userObject)),
                          }
                      });
                },
              ),
              TextButton(
                child: const Text('With Gallery'),
                onPressed: () {
                  Navigator.pop(context);
                  pickImageFromGallery().then((value) => {
                        if (value != null)
                          {
                            FireStorage()
                                .setImageUser(
                                    userObject: userObject, image: value)
                                .then((value) =>
                                    refreshImageUser(user: userObject)),
                          }
                      });
                },
              ),
            ],
          );
        });
  }

  bool verifDayTimer({required UserObject nameObject}) {
    return FireDatabase().verifIfUserSaveTimerToday(nameObject: nameObject);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff24303C),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    for (UserObject user in users)
                      Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2.5 - 40,
                            margin: const EdgeInsets.only(bottom: 30),
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xffF2EEEF),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    popUpAddImagePerson(userObject: user);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 30),
                                    height: 130,
                                    width: 130,
                                    child: user.linkImage != null &&
                                            user.linkImage != ""
                                        ? Image.network(user.linkImage!)
                                        : Image.asset('assets/test.png'),
                                  ),
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                Column(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Text(
                                          '${user.firstName} ${user.lastName}',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        StreamBuilder<int>(
                                          stream: listTimer[users.indexOf(user)]
                                              .rawTime,
                                          initialData:
                                              listTimer[users.indexOf(user)]
                                                  .rawTime
                                                  .value,
                                          builder: (context, snap) {
                                            final value = snap.data!;
                                            timervalue[users.indexOf(user)] =
                                                snap.data!;
                                            final displayTime =
                                                StopWatchTimer.getDisplayTime(
                                                    value,
                                                    hours: true,
                                                    minute: true,
                                                    second: true,
                                                    milliSecond: false);
                                            return Text(
                                              displayTime,
                                              style: const TextStyle(
                                                  fontSize: 40,
                                                  color: Color(0xffFE6A3C)),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            timerStart[users.indexOf(user)]
                                                ? Icons.pause_outlined
                                                : Icons.play_arrow_outlined,
                                            size: 50,
                                            color: dayOver[users.indexOf(user)]
                                                ? const Color(0xffA4B3B6)
                                                : null,
                                          ),
                                          onPressed: () => {
                                            if (!dayOver[users.indexOf(user)])
                                              {
                                                timerStart[users.indexOf(user)]
                                                    ? listTimer[
                                                            users.indexOf(user)]
                                                        .onStopTimer()
                                                    : listTimer[
                                                            users.indexOf(user)]
                                                        .onStartTimer(),
                                                setState(() {
                                                  timerStart[
                                                          users.indexOf(user)] =
                                                      !timerStart[
                                                          users.indexOf(user)];
                                                })
                                              }
                                          },
                                        ),
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.exit_to_app,
                                            size: 50,
                                            color: dayOver[users.indexOf(user)]
                                                ? const Color(0xffA4B3B6)
                                                : null,
                                          ),
                                          onPressed: () => {
                                            if (timerStart[users.indexOf(user)])
                                              {
                                                timerStart[users.indexOf(user)]
                                                    ? listTimer[
                                                            users.indexOf(user)]
                                                        .onStopTimer()
                                                    : listTimer[
                                                            users.indexOf(user)]
                                                        .onStartTimer(),
                                                setState(() {
                                                  timerStart[
                                                          users.indexOf(user)] =
                                                      !timerStart[
                                                          users.indexOf(user)];
                                                }),
                                              },
                                            FireDatabase()
                                                .addDateTimer(
                                                  nameObject: user,
                                                  timerDay: timervalue[
                                                          users.indexOf(user)]
                                                      .toInt(),
                                                )
                                                .then((value) =>
                                                    refreshUser(user: user)),
                                            setState(() {
                                              dayOver[users.indexOf(user)] =
                                                  true;
                                            }),
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              top: 10,
                              right: 40,
                              child: IconButton(
                                onPressed: () => refreshUser(user: user),
                                icon: Icon(
                                  Icons.arrow_forward,
                                  size: 60,
                                  color: (userSelected != null &&
                                          userSelected!.id == user.id)
                                      ? const Color(0xff7EDA91)
                                      : const Color(0xffA4B3B6),
                                ),
                              )),
                        ],
                      ),
                    ButtonAdd(onPressed: () => popUpAddPerson()),
                  ],
                ),
              ),
            ),
            userSelected != null
                ? Container(
                    width: MediaQuery.of(context).size.width -
                        MediaQuery.of(context).size.width / 2.5,
                    padding: const EdgeInsets.only(top: 30, bottom: 30),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          margin: const EdgeInsets.only(bottom: 30, right: 30),
                          decoration: BoxDecoration(
                            color: const Color(0xffF2EEEF),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          height:
                              (MediaQuery.of(context).size.height - 90) * 0.53,
                          child: TableCalendar<Event>(
                            firstDay: kFirstDay,
                            lastDay: kLastDay,
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            rangeStartDay: _rangeStart,
                            rangeEndDay: _rangeEnd,
                            calendarFormat: _calendarFormat,
                            rangeSelectionMode: _rangeSelectionMode,
                            eventLoader: _getEventsForDay,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            calendarStyle: const CalendarStyle(
                              // Use `CalendarStyle` to customize the UI
                              outsideDaysVisible: false,
                            ),
                            onDaySelected: _onDaySelected,
                            onRangeSelected: _onRangeSelected,
                            onFormatChanged: (format) {
                              if (_calendarFormat != format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              }
                            },
                            onPageChanged: (focusedDay) {
                              _focusedDay = focusedDay;
                            },
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                                margin: const EdgeInsets.only(right: 30),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF2EEEF),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                height:
                                    (MediaQuery.of(context).size.height - 90) *
                                        0.47,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "Heures effectuées le ${_selectedDay?.day.toString().padLeft(2, '0')}/${_selectedDay?.month.toString().padLeft(2, '0')}/${_selectedDay?.year}",
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.5,
                                          height: 50,
                                          child: ValueListenableBuilder<
                                                  List<Event>>(
                                              valueListenable: _selectedEvent,
                                              builder: (context, value, _) {
                                                return ListView.builder(
                                                  itemCount: value.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return ListTile(
                                                      title: Text(
                                                        getHourMinuteFormat(
                                                            value[index]
                                                                .dayTime),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 30,
                                                            color: Color(
                                                                0xffFE6A3C)),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Soit ",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            Text(
                                              getHourSupp(_selectedEvent.value),
                                              style: const TextStyle(
                                                  fontSize: 24,
                                                  color: Color(0xffFE6A3C),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const Text(
                                              " en temps supplementaires ",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Pour cette semaine, le total est de ",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Text(
                                          _selectedEvent.value.isNotEmpty
                                              ? getTimeWeek(
                                                  _selectedEvent.value)
                                              : getTimeWeekWithoutEvent(
                                                  isFourDaysWeekWithoutEvent(
                                                      userSelected:
                                                          userSelected!,
                                                      selectedDay:
                                                          _selectedDay)),
                                          style: const TextStyle(
                                              fontSize: 24,
                                              color: Color(0xffFE6A3C),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Positioned(
                                left: 15,
                                top: 10,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.date_range_sharp,
                                        size: 40,
                                      ),
                                      onPressed: () {
                                        bool isFourDaysWeekVerif =
                                            (_selectedEvent.value.isNotEmpty
                                                ? isFourDaysWeek(
                                                    events:
                                                        _selectedEvent.value)
                                                : isFourDaysWeekWithoutEvent(
                                                            userSelected:
                                                                userSelected!,
                                                            selectedDay:
                                                                _selectedDay) !=
                                                        null
                                                    ? isFourDaysWeekWithoutEvent(
                                                            userSelected:
                                                                userSelected!,
                                                            selectedDay:
                                                                _selectedDay)!
                                                        .isFourDaysWeek
                                                    : true);
                                        switchWeekType(
                                            userSelected: userSelected!,
                                            selectedDay: _selectedDay!,
                                            isFourDaysWeek:
                                                isFourDaysWeekVerif);
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15, left: 5),
                                      child: Text(
                                          (_selectedEvent.value.isNotEmpty
                                                  ? isFourDaysWeek(
                                                      events:
                                                          _selectedEvent.value)
                                                  : isFourDaysWeekWithoutEvent(
                                                              userSelected:
                                                                  userSelected!,
                                                              selectedDay:
                                                                  _selectedDay) !=
                                                          null
                                                      ? isFourDaysWeekWithoutEvent(
                                                              userSelected:
                                                                  userSelected!,
                                                              selectedDay:
                                                                  _selectedDay)!
                                                          .isFourDaysWeek
                                                      : true)
                                              ? "4"
                                              : "5",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                          )),
                                    )
                                  ],
                                ))
                          ],
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ));
  }

  String getHourMinuteFormat(int timer) {
    String hour = StopWatchTimer.getDisplayTimeHours(timer);
    String minute = StopWatchTimer.getDisplayTimeMinute(timer, hours: true);
    String seconds = StopWatchTimer.getDisplayTimeSecond(timer);

    return '$hour:$minute:$seconds';
  }

  String getHourSupp(List<Event> events) {
    String hourSupp = '';
    int hourSuppDefined = 0;
    int hourSuppFinal = 0;
    bool notHourSupp = false;

    for (var e in events) {
      if (e.isFourDaysWeek) {
        hourSuppDefined = (8 * 60 * 60 * 1000) + (45 * 60 * 1000);
      } else {
        hourSuppDefined = 7 * 60 * 60 * 1000;
      }
      hourSuppFinal = e.dayTime - hourSuppDefined;
      if (hourSuppFinal < 0) {
        notHourSupp = true;
        hourSuppFinal *= -1;
      }
    }

    hourSupp = notHourSupp
        ? '-${getHourMinuteFormat(hourSuppFinal)}'
        : getHourMinuteFormat(hourSuppFinal);

    return hourSupp;
  }

  String getTimeWeek(List<Event> events) {
    String hourSupp = '';
    int hourSuppFinal = 0;
    if (events.isNotEmpty) {
      hourSuppFinal = events[0].weekTime;
    }
    hourSupp = getHourMinuteFormat(hourSuppFinal);
    return hourSupp;
  }

  String getTimeWeekWithoutEvent(WeekTimerObject? weekTimerObject) {
    String hourSupp = '';
    int hourSuppFinal = 0;
    if (weekTimerObject != null) {
      hourSuppFinal = weekTimerObject.timerDurationWeek;
    }
    hourSupp = getHourMinuteFormat(hourSuppFinal);
    return hourSupp;
  }

  bool isFourDaysWeek({required List<Event> events}) {
    bool isFourDaysWeek = true;
    if (events.isNotEmpty) {
      isFourDaysWeek = events[0].isFourDaysWeek;
    }
    return isFourDaysWeek;
  }

  WeekTimerObject? isFourDaysWeekWithoutEvent(
      {required DateTime? selectedDay, required UserObject userSelected}) {
    WeekTimerObject? weekTimerObject;

    if (selectedDay != null) {
      weekTimerObject = FireDatabase()
          .getWeekOfUser(user: userSelected, dateTime: selectedDay);
    }

    return weekTimerObject;
  }

  void switchWeekType(
      {required UserObject userSelected,
      required DateTime selectedDay,
      required bool isFourDaysWeek}) {
    FireDatabase()
        .switchWeekTypeOfUser(
            user: userSelected,
            dateTime: selectedDay,
            isFourDaysWeek: isFourDaysWeek)
        .then((value) => {
              refreshUser(user: userSelected),
            });
  }

  Future<File?> pickImageFromCamera() async {
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) return null;

      return File(image.path);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return null;

      return File(image.path);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
      return null;
    }
  }
}

class ButtonAdd extends StatelessWidget {
  final Function() onPressed;

  const ButtonAdd({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5 - 40,
        margin: const EdgeInsets.only(bottom: 30),
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xffF2EEEF),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Ajouter un participant",
              style: TextStyle(
                  fontSize: 30,
                  color: Color(0xffFE6A3C),
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Icon(
              Icons.add_circle_outline,
              size: 50,
              color: Color(0xffFE6A3C),
            )
          ],
        ),
      ),
    );
  }
}

class Event {
  final int dayTime;
  final int weekTime;
  final bool isFourDaysWeek;

  const Event(
      {required this.dayTime,
      required this.weekTime,
      required this.isFourDaysWeek});
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
