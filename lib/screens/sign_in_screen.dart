import 'dart:async';
import 'dart:convert';

import 'package:connex_chat/screens/main_screen.dart';
import 'package:connex_chat/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  int passCode = 0630;
  int noPassCtn = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final TextEditingController _codeController = TextEditingController();


  void noPass() async {
    noPassCtn += 1;

    if (noPassCtn >= 3) {
      ScaffoldMessenger.of(context).clearSnackBars();
      showDialog(
        barrierDismissible: false,
        barrierColor: primaryColor.withOpacity(0.8),
          context: context, builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 200, height: 200, child: SvgPicture.asset('assets/icons/lock.svg', color: Colors.white)),
            SizedBox(height: 10),
            Text('3초 후 다시 시도해 주세요.', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600))
          ],
        )
      ));
      noPassCtn = 0;
    final timer = Timer.periodic(Duration(seconds: 3), (timer) {
      Navigator.pop(context);
      timer.cancel();
    });
      timer.isActive;
    }
  }

  Future<void> signIn() async {
    final body = {'email': _emailController.text, 'password': _passwordController.text};
    final response = await http.post(
      Uri.parse('http://192.168.11.2:8888/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body)
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['success']) {
        store.tkn = responseData['data']['token'];
        store.pref.setString('tkn', store.tkn);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인에 실패하였습니다. 이메일과 비밀번호를 다시 한번 확인해주세요.')));
        noPass();
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/simbol-white.png', width: 35),
                        SizedBox(width: 10),
                        Text('Connex Chat', style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Lexend', fontWeight: FontWeight.w600))
                      ],
                    ),
                    SizedBox(height: 40),
                    Text('안녕하세요!', style: TextStyle(color: Colors.white, fontSize: 37, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
                    Text('Connex Chat과 함께 오늘도 활기찬 하루되세요', style: TextStyle(color: Colors.white, fontSize: 17, fontFamily: 'Lexend', fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 1000,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40))
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Row(
                      children: [
                        SizedBox(width: 35),
                        Text('Login', style: TextStyle(color: primaryColor, fontSize: 27, fontFamily: 'Lexend', fontWeight: FontWeight.w700)),
                      ],
                    ),
                    SizedBox(height: 20),
                    _builderTextField('이메일을 입력해주세요', _emailController, _emailFocusNode, false),
                    SizedBox(height: 15),
                    _builderTextField('비밀번호를 입력해주세요', _passwordController, _passwordFocusNode, true),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 240,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none
                              )
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            final List list = [4532, 1346, 3475, 9134, 1237, 4372, 1238, 3241, 6431, 5329, 3214, 9465, 4321, 3742, 8632, 2372];
                            list.shuffle();
                            list.shuffle();
                            list.shuffle();
                            passCode = list[0];
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('인증 코드는 ${list[0]}입니다.')));
                            _codeController.text = list[0].toString();
                            setState(() {});
                          },
                          child: Container(
                            width: 115,
                            height: 60,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text('인증코드 전송', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Lexend' , fontWeight: FontWeight.w600)),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 80),
                    _builderButton('로그인 하기', () {
                      if (passCode.toString() != _codeController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('인증코드가 맞지 않습니다. 다시 한번 확인해주세요.')));
                        noPass();
                        return;
                      }
                      if (_emailController.text.isEmpty && _passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이메일과 비밀번호는 모두 필수 입력사항입니다. 모두 입력해주세요.')));
                        return;
                      }
                      if (_emailController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이메일은 필수 입력사항입니다. 이메일을 입력해주세요.')));
                        return;
                      }
                      if (_passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('비밀번호는 필수 입력사항입니다. 비밀번호를 입력해주세요.')));
                        return;
                      }
                      if (!_emailController.text.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이메일 형식이 올바르지 않습니다. 이메일 형식을 다시 확인해주세요.')));
                        return;
                      }
                      if (_emailController.text.contains(' ')) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이메일에는 공백문자를 포함할 수 없습니다. 이메일에 공백이 들어갔는지 확인해주세요.')));
                        return;
                      }
                      if (_passwordController.text.length < 4) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('보안상의 이유로 비밀번호는 4자리 이상이어야 합니다.')));
                        return;
                      }
                      signIn();
                    }, false),
                    SizedBox(height: 10),
                    _builderButton('회원가입 하러가기', () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입 기능은 준비 중입니다. 불편을 드려 죄송합니다.'))), true),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _builderTextField(String label, TextEditingController controller, FocusNode focusNode, bool isStyle2) {
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
          keyboardType: isStyle2 ? TextInputType.visiblePassword : TextInputType.emailAddress,
          obscureText: isStyle2,
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

  Widget _builderButton(String text, VoidCallback onTap, bool isStyle2) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 370,
        height: 60,
        decoration: BoxDecoration(
          color: !isStyle2 ? Colors.white : primaryColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: !isStyle2 ? primaryColor : Colors.white, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(color: isStyle2 ? Colors.white : primaryColor, fontSize: 15, fontFamily: 'Lexend', fontWeight: FontWeight.w600)),
      ),
    );
  }
}
