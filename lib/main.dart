import 'package:flutter/material.dart';
import 'package:new_keeper_2/ui/login_page.dart';
import 'package:new_keeper_2/style/theme.dart' as Theme;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Keeper',
      debugShowCheckedModeBanner: false,
      home: new LoginPage(),
    );
  }
}