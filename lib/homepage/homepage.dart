import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/provider/user.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Myhomepage extends StatefulWidget {
  final data;
  Myhomepage({key, this.data}) : super(key: key);

  @override
  State<Myhomepage> createState() => _MyhomepageState();
}

class _MyhomepageState extends State<Myhomepage> {
  final _textDiary = TextEditingController();
  bool checkParams = true;
  
  _writeDiary() async {
    if (_textDiary.text != "") {
      final db = FirebaseFirestore.instance;
      DateTime now = DateTime.now().toUtc();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      final users = context.read<UserProvider>().users;
      await db.collection('diaries').add({
        "date": formattedDate,
        "text": _textDiary.text,
        "user_id": users['user_id']
      });
      setState(() {
        _textDiary.text = "";
      });
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      checkParams = widget.data == null ? true : false;
      if (!checkParams) _textDiary.text = widget.data['text'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD3D3),
      body: SingleChildScrollView(
          child: Column(
        children: [
          const SizedBox(height: 50),
          Align(
            alignment: Alignment.center,
            child: Text(
              checkParams ? 'How was your day ?' : widget.data['date'],
              style: const TextStyle(fontSize: 20, fontFamily: 'Outfit'),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            width: 340,
            height: 500,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                enabled: checkParams,
                controller: _textDiary,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Write your diary here',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          )
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (checkParams){
            if (await _writeDiary()) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Save As'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          } else {
            Navigator.pop(context);
          }
        },
        backgroundColor: const Color.fromRGBO(250, 180, 255, 100),
        child: checkParams
            ? const Icon(Icons.post_add)
            : const Icon(Icons.arrow_back),
      ),
    );
  }
}
