import 'dart:convert';

import 'package:connex_chat/save_image.dart';
import 'package:connex_chat/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'unknown';

  Future<void> getUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.11.2:8888/users/me'),
        headers: {'Authorization': 'Bearer ${store.tkn}'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        userName = responseData['data']['name'];
        store.pref.setString('userName', userName);
      }
    } catch (e) {
      userName = store.pref.getString('userName') ?? 'unknown';
    }

    setState(() {});
  }

  Future<void> getUserList() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.11.2:8888/employees'),
        headers: {'Authorization': 'Bearer ${store.tkn}'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List list = responseData['data']['data'];
        store.userList = list.map((e) => User(id: e['id'], name: e['name'], position: e['position'], profileImage: e['profileImage'])).toList();
        store.pref.setString('userList', jsonEncode(list));
      }
    } catch (e) {
      List list = jsonDecode(store.pref.getString('userList') ?? '[]');
      store.userList = list.map((e) => User(id: e['id'], name: e['name'], position: e['position'], profileImage: e['profileImage'])).toList();
      store.pref.setString('userList', jsonEncode(list));
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.person_rounded, color: primaryColor,),
                  ),
                  SizedBox(width: 10),
                  Text('$userName 님', style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(width: 20, height: 20, child: SvgPicture.asset('assets/icons/clock.svg', color: Colors.white)),
                      Text('00:00:00', style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Lexend', fontWeight: FontWeight.w400))
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('사원 목록', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                          GestureDetector(onTap: () {}, child: Container(width: 25, height: 25, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(5)), child: SvgPicture.asset('assets/icons/Arrange.svg', color: Colors.white)))
                        ],
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.only(bottom: 100, top: 5),
                          separatorBuilder: (context, index) => SizedBox(height: 10,),
                          itemCount: store.userList.length,
                          itemBuilder: (context, index) {
                            final user = store.userList[index];
                            return GestureDetector(
                              onLongPress: () {
                                showDialog(context: context, builder: (context) => Dialog(
                                  backgroundColor: Colors.white,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FutureBuilder(future: saveImage(user.profileImage, '$index$userName.png'), builder: (context, snapshot) {
                                        if(snapshot.hasData && snapshot.data != null) {
                                          return ShaderMask(
                                            blendMode: BlendMode.dstIn,
                                            shaderCallback: (bounds) => LinearGradient(colors: [Colors.white, Colors.white, Colors.transparent]).createShader(bounds),
                                            child: Container(
                                                width: 200,
                                                height: 200,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                                                    image: DecorationImage(image: FileImage(snapshot.data!), fit: BoxFit.cover))
                                            ),
                                          );
                                        } else {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(

                                            ),
                                            child: Icon(Icons.person),
                                          );
                                        }
                                      },),
                                      SizedBox(width: 10),
                                      Text('${user.name} ${user.position}', style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                ));
                              },
                              onPanEnd: (details) {
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  FutureBuilder(future: saveImage(user.profileImage, '$index$userName.png'), builder: (context, snapshot) {
                                    if(snapshot.hasData && snapshot.data != null) {
                                      return ShaderMask(
                                        blendMode: BlendMode.dstIn,
                                        shaderCallback: (bounds) => LinearGradient(colors: [Colors.white, Colors.white, Colors.transparent]).createShader(bounds),
                                        child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                                              image: DecorationImage(image: FileImage(snapshot.data!), fit: BoxFit.cover))
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(

                                        ),
                                        child: Icon(Icons.person),
                                      );
                                    }
                                  },),
                                  SizedBox(width: 10),
                                  Text('${user.name} ${user.position}', style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600))
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
