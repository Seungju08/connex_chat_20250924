import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../store.dart';

class ChatDetailScreen extends StatefulWidget {
  final String roomName;
  final String sectionName;
  final int roomId;
  const ChatDetailScreen({super.key, required this.roomName, required this.sectionName, required this.roomId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> messages = [];
  Map<int, String> userProfiles = {};
  Map<int, String> userNames = {};

  bool isLock = false;

  Future<void> readMessage() async {
    final body = {'chatroomId': widget.roomId};
    final response = await http.put(
      Uri.parse('http://192.168.11.18:7006/messages/read'),
      headers: {'Authorization': 'Bearer ${store.tkn}', 'Content-Type': 'application/json'},
      body: jsonEncode(body)
    );
  }

  Future<void> send() async {
    if (controller.text.isEmpty) {
      return;
    }

    webSocket!.add(jsonEncode({
      "event": "send_message",
      "body": {
        "content": controller.text
      }
    }));
  }

  Future<void> sendss() async {

    webSocket!.add(jsonEncode({
      "event": "send_message",
      "body": {
        "content": laterMessage
      }
    }));
  }

  bool laterrrrr = false;

  WebSocket? webSocket;

  String laterMessage = '';

  final TextEditingController _numController = TextEditingController();

  Future<void> sendLater() async {
    laterrrrr = true;
      Navigator.pop(context);
      laterMessage = controller.text;
      controller.clear();
    final timer = Timer.periodic(Duration(seconds:  3), (timer) {
    laterrrrr = false;
      sendss();
      timer.cancel();

    });

    timer.isActive;
  }

  Future<void> connectWebSocket() async {
    webSocket = await WebSocket.connect('ws://192.168.11.18:7006/ws/chatrooms/${widget.roomId}/messages?token=${store.tkn}');

    webSocket?.listen((event) {
      final data = jsonDecode(event);

      print(data);

      if (data['name'] == 'Start Connection') {
        final list = List<Map<String, dynamic>>.from(data['response']['data']['messages']);

        for (var m in list) {
          final senderId = m['senderId'];

          if (senderId != null) {
            userNames[senderId] = m['senderName'];
            userProfiles[senderId] = m['senderProfile'];
          }
        }

        setState(() => messages = list);
      }

      if (data['name'] == 'Unread Messages Update') {
        final m = Map<String, dynamic>.from(data['response']['data']);
        final senderId = m['senderId'];
        m['senderName'] = userNames[senderId] ?? store.userList.firstWhere((element) => element.id == senderId).name;
        m['senderProfile'] = userProfiles[senderId] ?? store.userList.firstWhere((element) => element.id == senderId).profileImage;

        setState(() => messages.add(m));
      }
    });
  }


  @override
  void initState() {
    super.initState();
    readMessage();
    connectWebSocket();
  }

  @override
  void dispose() {
    super.dispose();
    webSocket?.close();
    readMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: SvgPicture.asset('assets/icons/back.svg', color: Colors.white)),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.sectionName, style: TextStyle(color: Colors.white, fontSize: 17, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                      Text(widget.roomName, style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Spacer(),
                  GestureDetector(onTap: () {
                    setState(() {
                    isLock = !isLock;
                    });
                  }, child: Icon(Icons.lock_outline_rounded, color: isLock ? Colors.white : Colors.grey, size: 35))
                ],
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final m = messages[index];
                          final isMine = m['isMyMessage'];

                          return isMine ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                        color: isMine ? primaryColor : Color(0xffF9F6FA),
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15), topLeft: Radius.circular(isMine ? 15 : 1), topRight: Radius.circular(isMine ? 1 : 15))
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(m['content'], style: TextStyle(color: isMine ? Colors.white : Colors.black, fontSize: 13, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                                    )),
                                SizedBox(height: 3),
                                Text(m['timestamp'])
                              ],
                            ),
                          ) : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    SizedBox(width: 30, height: 30, child: CircleAvatar(backgroundImage: NetworkImage(m['senderProfile']))),
                                    SizedBox(width: 10),
                                    Text(m['senderName'], style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600))
                                  ],
                                ),
                                SizedBox(height: 5),
                                Container(
                                    decoration: BoxDecoration(
                                        color: isMine ? primaryColor : Color(0xffF9F6FA),
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15), topLeft: Radius.circular(isMine ? 15 : 1), topRight: Radius.circular(isMine ? 1 : 15))
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(m['content'], style: TextStyle(color: isMine ? Colors.white : Colors.black, fontSize: 13, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                                    )),
                                SizedBox(height: 3),
                                Text(m['timestamp'])
                              ],
                            ),
                          );

                        }
                      ),
                    ),
                    Visibility(
                      visible: laterrrrr,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.8),
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15), topLeft: Radius.circular(15), topRight: Radius.circular(1))
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(laterMessage, style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3)))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 300,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isLock ?Colors.grey.withOpacity(0.7) : Colors.white,
                              border: Border.all(color: isLock ? Colors.grey : primaryColor, width: 1.5),
                              borderRadius: BorderRadius.circular(10)
                            ),
                            alignment: Alignment.center,
                            child: Visibility(
                              visible: !isLock,
                              child: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                  ),
                                  label: Text('대화 내용을 입력해주세요...', style: TextStyle(color: Colors.grey, fontSize: 15, fontFamily: 'Lexend'),)
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(onTap: () {
                            if (!isLock) {
                              showDialog(context: context, builder: (context) => Dialog(
                                backgroundColor: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Spacer(),
                                          GestureDetector(onTap: () => Navigator.pop(context), child: SvgPicture.asset('assets/icons/close.svg')),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 160,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(),
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: Stack(
                                              children: [
                                                TextField(
                                                  controller: _numController,
                                                  keyboardType: TextInputType.number,
                                                ),
                                                Positioned(top: 15, left: 120, child: Text('초', style: TextStyle(color: Colors.grey, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600)))
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () {
                                              sendLater();
                                            },
                                            child: Container(
                                              width: 100,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: primaryColor,
                                                  borderRadius: BorderRadius.circular(10)
                                              ),
                                              alignment: Alignment.center,
                                              child: Text('예약전송', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                            }
                          }, child: SizedBox(width: 30, child: SvgPicture.asset('assets/icons/time_send.svg', color: isLock ? Colors.grey : primaryColor))),
                          SizedBox(width: 10),
                          GestureDetector(onTap: () {
                            if (!isLock) {
                              send();
                            }
                          }, child: SizedBox(width: 30, child: SvgPicture.asset('assets/icons/send-fill.svg', color: controller.text.isEmpty || isLock ? Colors.grey : primaryColor))),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
