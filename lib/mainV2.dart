import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyHomePage2 extends StatefulWidget {
  const MyHomePage2({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage2> createState() => _MyHomePage2State();
}

class _MyHomePage2State extends State<MyHomePage2> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
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
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff24303C),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2.5,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    SizedBox(
                      height: 30,
                    ),
                    Information(),
                    Information(),
                    Information(),
                    Information(),
                    Information(),
                    Information(),
                    Information(),
                    Information(),
                    ButtonAdd(),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width -
                  MediaQuery.of(context).size.width / 2.5,
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 50),
                    margin: const EdgeInsets.only(bottom: 30, right: 30),
                    decoration: BoxDecoration(
                      color: const Color(0xffF2EEEF),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    height: 475,
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
                          padding: const EdgeInsets.only(top: 50),
                          margin: const EdgeInsets.only(bottom: 30, right: 30),
                          decoration: BoxDecoration(
                            color: const Color(0xffF2EEEF),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          height: 400,
                          child: Column(
                            children: [
                              Text(
                                "Heures effectuées le ${_selectedDay?.day}/${_selectedDay?.month}/${_selectedDay?.year}",
                                style: const TextStyle(fontSize: 30),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width -
                                    MediaQuery.of(context).size.width / 2.5,
                                height: 100,
                                child: ValueListenableBuilder<List<Event>>(
                                    valueListenable: _selectedEvents,
                                    builder: (context, value, _) {
                                      return ListView.builder(
                                        itemCount: value.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            onTap: () =>
                                                print('${value[index]}'),
                                            title: Text(
                                              '${value[index]}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 30,
                                                  color: Color(0xffFE6A3C)),
                                            ),
                                          );
                                        },
                                      );
                                    }),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Soit ",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  Text(
                                    "00:00",
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Color(0xffFE6A3C),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    " en temps supplementaires ",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Pour cette semaine, le total est de  ",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  Text(
                                    "00:00",
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Color(0xffFE6A3C),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Positioned(
                          left: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.date_range_sharp,
                                  size: 50,
                                ),
                                onPressed: () {},
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 22, left: 10),
                                child: Text("5",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                    )),
                              )
                            ],
                          ))
                    ],
                  )
                ],
              ),
            )
          ],
        ));
  }
}

class Information extends StatelessWidget {
  const Information({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              Container(
                margin: const EdgeInsets.only(left: 30),
                height: 130,
                width: 130,
                child: Image.asset("assets/test.png"),
              ),
              const SizedBox(
                width: 30,
              ),
              Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Name",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "00:00:00",
                        style: TextStyle(
                            fontSize: 50, color: const Color(0xffFE6A3C)),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(
                        Icons.play_arrow_outlined,
                        size: 50,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Icon(
                        Icons.exit_to_app,
                        size: 50,
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        const Positioned(
            top: 10,
            right: 10,
            child: Icon(
              Icons.verified,
              size: 60,
              color: Color(0xff7EDA91),
            )),
      ],
    );
  }
}

class ButtonAdd extends StatelessWidget {
  const ButtonAdd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {print("Add a person")},
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
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = {
  for (var item in List.generate(50, (index) => index))
    DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5): List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}'))
}..addAll({
    kToday: [
      const Event('Today\'s Event 1'),
      const Event('Today\'s Event 2'),
    ],
  });

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
