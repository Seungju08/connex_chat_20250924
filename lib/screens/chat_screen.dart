import 'dart:convert';

import 'package:connex_chat/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../save_image.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final FocusNode _sectionFocusNode = FocusNode();
  final FocusNode _roomFocusNode = FocusNode();

  String currentSection = '';
  List<String> sections = [];
  List<Room> filteredRoom = [];

  void filterRoom() async {
    filteredRoom = store.roomList.where((element) => element.section == (currentSection)).toList();
    store.updateScreen();
  }

  Future<void> createRoom() async {
    final body = {'roomName': _roomController.text, 'participants': store.selectedUser};
    final response = await http.post(
      Uri.parse('http://192.168.11.2:8888/chatrooms'),
      headers: {'Authorization': 'Bearer ${store.tkn}', 'Content-Type': 'application/json'},
      body: jsonEncode(body)
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final e = responseData['data'];

      if (!sections.contains(_sectionController.text)) {
        sections.add(_sectionController.text);
      }

      final Map<String, dynamic> roomInfo = jsonDecode(store.pref.getString('roomInfo') ?? '{}');

      roomInfo[e['id'].toString()] = {
        'section': _sectionController.text
      };

      store.pref.setString('roomInfo', jsonEncode(roomInfo));

      Navigator.pop(context);
      store.getRoomList();
    }
  }

  @override
  void initState() {
    super.initState();
    _sectionFocusNode.addListener(() => store.updateScreen());
    _roomFocusNode.addListener(() => store.updateScreen());
    store.getRoomList().then((value) {
      sections = store.roomList.map((e) => e.section).toSet().toList();
      currentSection = ' ';
      filterRoom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('채팅방 목록', style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                  GestureDetector(onTap: () => showDialog(context: context, builder: (context) => Dialog(
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('채팅방 생성하기', style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                              GestureDetector(onTap: () => Navigator.pop(context), child: SvgPicture.asset('assets/icons/close.svg')),
                            ],
                          ),
                          SizedBox(height: 15),
                          _builderTextField('섹션 이름을 입력해주세요', _sectionController, _sectionFocusNode),
                          SizedBox(height: 10),
                          _builderTextField('채팅방 이름을 입력해주세요', _roomController, _roomFocusNode),
                          SizedBox(height: 20),
                          SizedBox(height: 35, child: ListView.separated(
                            separatorBuilder: (context, index) => SizedBox(width: 10),
                            scrollDirection: Axis.horizontal,
                            itemCount: store.userList.length,
                            itemBuilder: (context, index) {
                              final user = store.userList[index];
                              final selected = store.selectedUser.contains(user.id);

                              return Opacity(
                                opacity: selected ? 1 : 0.5,
                                child: GestureDetector(
                                  onTap: () {
                                    selected ? store.selectedUser.remove(user.id) : store.selectedUser.add(user.id);
                                    store.updateScreen();
                                  },
                                  child: Row(
                                    children: [
                                      FutureBuilder(future: saveImage(user.profileImage, '$index${user.name}as.png'), builder: (context, snapshot) {
                                        if(snapshot.hasData && snapshot.data != null) {
                                          return Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(100),
                                                  image: DecorationImage(image: FileImage(snapshot.data!), fit: BoxFit.cover)),
                                          );
                                        } else {
                                          return Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(),
                                            child: Icon(Icons.person),
                                          );
                                        }
                                      },),
                                      SizedBox(width: 5),
                                      Text('${user.name} ${user.position}', style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => createRoom(),
                            child: Container(
                              width: 370,
                              height: 55,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text('생성하기', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                            ),
                          )
                        ],
                      ),
                    ),
                  )), child: SvgPicture.asset('assets/icons/chat-plus-outline.svg', color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40))
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Row(
                      children: [
                        SizedBox(width: 20),
                        for (var section in sections)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(onTap: () => setState(() {
                              currentSection = section;
                              filterRoom();
                            }), child: Text(section, style: TextStyle(color: section == currentSection ? primaryColor : Colors.black.withOpacity(0.6), fontSize: 17, fontFamily: 'Lexend',  fontWeight: FontWeight.w600))),
                          )
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        separatorBuilder: (context, index) => SizedBox(height: 10),
                        itemCount: filteredRoom.length,
                        itemBuilder: (context, index) {
                          final room = filteredRoom[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              width: 370,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 2, spreadRadius: 2)]
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(width: 200, child: Text(room.roomName, style: TextStyle(color: Colors.black, fontSize: 17, fontFamily: 'Lexend', fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, maxLines: 1)),
                                        SizedBox(width: 200, child: Text(room.lastMessage, style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, maxLines: 1)),
                                      ],
                                    ),
                                    Text(room.lastMessageTime),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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

  Widget _builderTextField(String label, TextEditingController controller, FocusNode focusNode) {
    final hasFocus = focusNode.hasFocus;

    return Container(
      width: 370,
      height: 65,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: hasFocus ? primaryColor : Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: hasFocus ? primaryColor.withOpacity(0.2) : Colors.transparent, offset: Offset(0, 2), blurRadius: 2, spreadRadius: 2)]
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
              isDense: true,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              label: Text(label, style: TextStyle(color: Colors.grey, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none
              )
          ),
        ),
      ),
    );
  }
}
