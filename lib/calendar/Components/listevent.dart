import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/homepage/homepage.dart';
import 'package:my_app/provider/user.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Listevents extends StatefulWidget {
  Listevents({key, required this.date}) : super(key: key);
  String date;

  @override
  State<Listevents> createState() => _ListeventsState();
}

class _ListeventsState extends State<Listevents> {
  List listData = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    final db = FirebaseFirestore.instance;
    final users = context.read<UserProvider>().users;
    DateTime dateTime = DateTime.parse(widget.date);
    String timeNew = DateFormat('yyyy-MM-dd').format(dateTime);
    final queryDiary = await db
        .collection('diaries')
        .where('user_id', isEqualTo: users['user_id'])
        .where('date', isEqualTo: timeNew)
        .get();
    for (final data in queryDiary.docs) {
      setState(() {
        listData.add({
          "date": data['date'],
          "text": data['text'],
          "user_id": data['user_id'],
          "diary_id": data.id,
        });
      });
    }
  }

  _deleteDiary(String id) async {
    final db = FirebaseFirestore.instance;
    await db.collection('diaries').doc(id).delete();
    return true;
  }

  Future<void> _dialogBuilder(BuildContext context ,String id) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete ?'),
          content: const Text('Are you sure you want to delete'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Disable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Enable'),
              onPressed: () async {
                if (await _deleteDiary(id)) {
                  Navigator.of(context).pop();
                  setState(() {
                    listData.removeWhere((element) => element['diary_id'] == id);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFD3D3), Color.fromRGBO(250, 180, 255, 100)])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: listData.isNotEmpty
                ? ListView(
                    children: List.generate(
                        listData.length,
                        (index) => Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Myhomepage(data: listData[index])),
                                );
                              },
                              onLongPress: () => _dialogBuilder(context , listData[index]['diary_id']),
                              child: Container(
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                ),
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(listData[index]['text'])),
                              ),
                            ))),
                  )
                :const  Align(
                    alignment: Alignment.center,
                    child: Text('Not found'),
                  )),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          backgroundColor: const Color.fromRGBO(250, 180, 255, 100),
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
