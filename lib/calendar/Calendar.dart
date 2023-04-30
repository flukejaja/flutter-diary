import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:my_app/calendar/Components/listevent.dart';
import 'package:my_app/homepage/homepage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import './Class/events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/provider/user.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? selectedDate;
  DateTime? _selectedEvents;
  Map<DateTime, List<Event>> events = {};
  
  @override
  void initState() {
    super.initState();
    _getDateEvents();
  }

  _getDateEvents() async {
    List dateList = [];
    final db = FirebaseFirestore.instance;
    final users = context.read<UserProvider>().users;
    final queryDiary = await db
        .collection('diaries')
        .where('user_id', isEqualTo: users['user_id'])
        .get();
    for (final data in queryDiary.docs) {
      dateList.add(data.data());
    }
    Map<DateTime, List<Event>> output = {};
    for (var entry in dateList) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(entry['date'] , true);
      if (!output.containsKey(date)) {
        output[date] = [];
      }
      output[date]!.add(Event(entry['text']));
    }
    setState(() {
      events = output;
    }); 
  }



  List<Object> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFD3D3),
        body: SingleChildScrollView(
            child: Column(
          children: [
            const SizedBox(height: 50),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Calendar',
                style: TextStyle(fontSize: 20, fontFamily: 'Outfit'),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              color: Colors.white,
              height: 500,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: TableCalendar(
                  locale: "en_US",
                  rowHeight: 43,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  availableGestures: AvailableGestures.all,
                  firstDay: DateTime(DateTime.now().year - 10),
                  lastDay: DateTime(DateTime.now().year + 10),
                  focusedDay: selectedDate ?? _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Listevents(date: selectedDay.toString())),
                      ).then((value) => _getDateEvents());
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  eventLoader: _getEventsForDay,
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  onHeaderTapped: (DateTime focusedDay) async {
                    DateTime? picked = await showMonthPicker(
                      selectedMonthTextColor: Colors.black,
                      unselectedMonthTextColor: Colors.black,
                      selectedMonthBackgroundColor: const Color(0xFFFFD3D3),
                      headerColor: const Color.fromRGBO(250, 180, 255, 100),
                      context: context,
                      initialDate: focusedDay,
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        )));
  }
}
