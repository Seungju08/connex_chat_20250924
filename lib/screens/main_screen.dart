import 'package:connex_chat/screens/chat_screen.dart';
import 'package:connex_chat/screens/home_screen.dart';
import 'package:connex_chat/screens/profile_screen.dart';
import 'package:connex_chat/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: currentIndex,
              children: [HomeScreen(), ChatScreen(), ProfileScreen()],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  width: 370,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), spreadRadius: 2, blurRadius: 2, offset: Offset(0, 2))]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _builderItem(0, 'Home', 'home-fill.svg', 'home-outline.svg'),
                      Stack(
                        children: [
                          _builderItem(1, 'Chat', 'chat-dots-fill.svg', 'chat-dots-outline.svg'),
                          Positioned(
                            left: 35,
                            top: 5,
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle
                              ),
                              alignment: Alignment.center,
                              child: Text('${store.unreadCount}', style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                            ),
                          )
                        ],
                      ),
                      _builderItem(2, 'Profile', 'person-fill.svg', 'person-outline.svg'),
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

  Widget _builderItem(int index, String text, String selected, String unSelected) {
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(currentIndex == index ? 'assets/icons/$selected' : 'assets/icons/$unSelected', color: primaryColor),
            Text(text, style: TextStyle(color: primaryColor, fontSize: 15, fontFamily: 'Lexend', fontWeight: currentIndex == index ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
