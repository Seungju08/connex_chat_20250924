import 'package:connex_chat/screens/sign_in_screen.dart';
import 'package:connex_chat/store.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final double _minOffset = 5;
  final double _maxOffset = 100;
  Offset buttonOffset = Offset(0, 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      store.getPref(context);
      store.startAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 250),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(duration: Duration(milliseconds: 700), opacity: store.logo ? 1 : 0, child: AnimatedRotation(duration: Duration(milliseconds: 700), turns: store.logo ? 0 : 0.2, curve: Curves.easeOutBack, child: Image.asset('assets/images/simbol-white.png'))),
                SizedBox(width: 10),
                Stack(
                  children: [
                    Text('Connex Chat', style: TextStyle(color: Colors.white, fontSize: 33, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                    AnimatedSlide(
                      duration: Duration(milliseconds: 700),
                      offset: Offset(store.logoText ? 1 : 0, 0),
                      child: Container(
                        width: 214,
                        height: 40,
                        color: primaryColor,
                      ),
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 10),
            AnimatedOpacity(duration: Duration(milliseconds: 700), opacity: store.slogan ? 1 : 0, child: AnimatedSlide(duration: Duration(milliseconds: 700), offset: Offset(0, store.slogan ? 0 : 1), child: Text('언제 어디서든 안정적인 근무 환경을 위해', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600)))),
            SizedBox(height: 150),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 70,
                  height: 170,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.5)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.circular(100)
                  ),
                ),
                Positioned(top: 55, child: Icon(Icons.keyboard_arrow_up, size: 30, color: Colors.white.withOpacity(0.5))),
                Icon(Icons.keyboard_arrow_up, size: 30, color: Colors.white),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 600),
                  opacity: store.buttonBg ? 0 : 1,
                  child: AnimatedSlide(
                    duration: Duration(milliseconds: 700),
                    offset: Offset(0, store.buttonBg ? -1 : 0),
                    child: Container(
                      width: 70,
                      height: 170,
                      color: primaryColor,
                    ),
                  ),
                ),
                Positioned(
                  bottom: buttonOffset.dy,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 700),
                    opacity: store.button ? 1 : 0,
                    child: AnimatedSlide(
                      duration: Duration(milliseconds: 700),
                      offset: Offset(0, store.loop ? -0.25 : 0),
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            final next = buttonOffset.dy + -details.delta.dy;
                            final clamp = next.clamp(_minOffset, _maxOffset);
                            buttonOffset = Offset(0, clamp);
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            if (buttonOffset.dy >= _maxOffset) {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                              return;
                            } else {
                              buttonOffset = Offset(0, _minOffset);
                            }
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle
                          ),
                          alignment: Alignment.center,
                          child: Text('NEXT', style: TextStyle(color: primaryColor, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
