import 'package:flutter/material.dart';
import 'package:dolang/pages/main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MainPage(), theme: ThemeData(primarySwatch: Colors.deepPurple));
  }
}
