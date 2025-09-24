import 'dart:async';
import 'dart:convert';

import 'package:connex_chat/screens/main_screen.dart';
import 'package:connex_chat/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final store = Store();

Color primaryColor = Color(0xff4F27B3);

class Store {
  final ValueNotifier<int> updateCtn = ValueNotifier(0);
  void updateScreen() => updateCtn.value += 1;

  bool intro = false;
  String tkn = '';
  late SharedPreferences pref;

  void getPref(BuildContext context) async {
    pref = await SharedPreferences.getInstance();
    tkn = pref.getString('tkn') ?? '';
    intro = pref.getBool('intro') ?? false;

    if (tkn != '') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
      return;
    }

    if (intro) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
      return;
    }
  }

  bool logo = false;
  bool logoText = false;
  bool slogan = false;
  bool button = false;
  bool buttonBg = false;
  bool loop = false;

  void startAnimation() async {
    await Future.delayed(Duration(seconds: 3));
    logo = true;
    updateScreen();
    await Future.delayed(Duration(milliseconds: 700));
    logoText = true;
    updateScreen();
    await Future.delayed(Duration(milliseconds: 700));
    slogan = true;
    updateScreen();
    await Future.delayed(Duration(milliseconds: 700));
    button = true;
    updateScreen();
    await Future.delayed(Duration(milliseconds: 700));
    buttonBg = true;
    updateScreen();
    await Future.delayed(Duration(milliseconds: 700));

    startLoopAnimation();

    pref.setBool('intro', true);
  }

  void startLoopAnimation() {
    Timer.periodic(Duration(seconds: 2), (timer) async {
      loop = !loop;
      updateScreen();
      await Future.delayed(Duration(milliseconds: 300));
      loop = !loop;
      updateScreen();
    });
  }

  int unreadCount = 0;

  Future<void> getRoomList() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.11.18:7006/chatrooms'),
        headers: {'Authorization': 'Bearer ${store.tkn}'}
      ).timeout(Duration(seconds: 5));


      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> roomInfo = jsonDecode(pref.getString('roomInfo') ?? "{}");
        final responseData = jsonDecode(response.body);
        List list = responseData['data']['chatrooms'];
        pref.setString('roomList', jsonEncode(roomList));
        roomList = list.map((e) {
          final local = roomInfo[e['id'].toString()] ?? {};
          return Room(
              id: e['id'],
              roomName: e['roomName'],
              lastMessage: e['lastMessage'],
              lastMessageTime: e['lastMessageTime'],
              unreadCount: e['unreadCount'],
              participants: List<int>.from(e['participants']),
              section: local['section'] ?? '',
              isStar: local['isStar'] ?? false
          );
        }).toList();

        updateScreen();
      }
    } catch (e) {
      List list = jsonDecode(pref.getString('roomList') ?? '[]');
      final Map<String, dynamic> roomInfo = jsonDecode(pref.getString('roomInfo') ?? "{}");
      roomList = list.map((e) {
        final local = roomInfo[e['id'].toString()] ?? {};
        return Room(
            id: e['id'],
            roomName: e['roomName'],
            lastMessage: e['lastMessage'],
            lastMessageTime: e['lastMessageTime'],
            unreadCount: e['unreadCount'],
            participants: List<int>.from(e['participants']),
            section: local['section'] ?? '',
            isStar: local['isStar'] ?? false
        );
      }).toList();
    }

    updateScreen();
  }

  List<User> userList = [];
  List<Room> roomList = [];
  List<int> selectedUser = [];
  List<UnreadChat> unreadChatList = [];
}

class User {
  final int id;
  final String name;
  final String profileImage;
  final String position;

  User({required this.id, required this.name, required this.profileImage, required this.position});
}

class Room {
  final int id;
  final String roomName;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final List<int> participants;
  final String section;
  final bool isStar;

  Room({required this.id, required this.roomName, required this.lastMessage, required this.lastMessageTime, required this.unreadCount, required this.participants, required this.section, required this.isStar});
}

class UnreadChat {
  final int roomId;
  final String roomName;
  final String lastMessage;
  final int unreadCount;
  final List<Map<String, dynamic>> participants;

  UnreadChat({required this.roomId, required this.roomName, required this.lastMessage, required this.unreadCount, required this.participants});
}
