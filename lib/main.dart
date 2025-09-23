import 'package:connex_chat/screens/intro_screen.dart';
import 'package:connex_chat/store.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    ValueListenableBuilder(
      valueListenable: store.updateCtn,
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: IntroScreen(),
        );
      },
    ),
  );
}
