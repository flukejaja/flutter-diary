import 'package:flutter/material.dart';
import 'package:my_app/auth/login.dart';
import 'package:my_app/layout/bottomnavbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/profile/Components/setting.dart';
import 'package:my_app/provider/user.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProfiePage extends StatefulWidget {
  const ProfiePage({super.key});

  @override
  State<ProfiePage> createState() => _ProfiePageState();
}

class _ProfiePageState extends State<ProfiePage> {
  bool checkReminder = false;

  _actionBottom(String key) {
    switch (key) {
      case 'Logout':
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
        break;
      case 'Reminder':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NavigationBarPage()),
        );
        break;
      case 'Settings':
        Navigator.push(context, MaterialPageRoute(builder: (context) => Settingpage()),).then((res) => _getDiary());
    }
  }

  @override
  void initState() {
    _getDiary();
    super.initState();
  }

  _getDiary() async {
    final users = context.read<UserProvider>().users;
    final db = FirebaseFirestore.instance;
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final quertDiary = await db
        .collection('diaries')
        .where('user_id', isEqualTo: users['user_id'])
        .where('date', isEqualTo: formattedDate)
        .get();
    if (quertDiary.docs.isEmpty) {
      setState(() {
        checkReminder = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = context.read<UserProvider>().users;
    List<dynamic> titleProfie = [
      {
        "icon": '0xe491',
        "title": users['name'],
      },
      {"icon": '0xe57f', "title": "Settings"},
      {"icon": '0xe44f', 'title': "Reminder"},
      {"icon": '0xe113', "title": "Theme"},
      {"icon": '0xe3b3', "title": "Logout"}
    ];
    return Scaffold(
        backgroundColor: const Color(0xFFFFD3D3),
        body: SingleChildScrollView(
            child: Column(
          children: [
            const SizedBox(height: 60),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Profile',
                style: TextStyle(fontSize: 20, fontFamily: 'Outfit'),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                  height: 200,
                  width: 200,
                  child: ClipOval(
                    child: SizedBox.fromSize(
                      size: Size.fromRadius(48), // Image radius
                      child: Image.asset(
                        users['image'] ?? 'assets/images/5231019.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )),
            ),
            Column(
                children: List.generate(
                    titleProfie.length,
                    (index) => Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            _actionBottom(titleProfie[index]['title']);
                          },
                          child: Container(
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                titleProfie[index]['icon'] != '0xe44f'
                                    ? Icon(IconData(
                                        int.parse(titleProfie[index]['icon']),
                                        fontFamily: 'MaterialIcons'))
                                    : Container(
                                        width: 30,
                                        height: 30,
                                        child: Stack(
                                          children: [
                                            const Icon(
                                              Icons.notifications,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                            if (checkReminder)
                                              Container(
                                                width: 30,
                                                height: 30,
                                                alignment: Alignment.topRight,
                                                margin: EdgeInsets.only(top: 5),
                                                child: Container(
                                                  width: 15,
                                                  height: 15,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xffc32c37),
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 1)),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                Text(titleProfie[index]['title']),
                                index != 0
                                    ? const Icon(Icons.arrow_forward_ios)
                                    : const SizedBox.shrink()
                              ],
                            ),
                          ),
                        ))))
          ],
        )));
  }
}
