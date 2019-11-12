import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // To counter Flutter update inconvenient
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then( (_) {runApp(new PewPewPew()); });
}

class PewPewPew extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: 'Pew Pew Pew !!!',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Color(0xFFC0F0E8),
        primaryColor: Colors.lightBlue, // 0xFF80E1D1
        fontFamily: "Heroes",
        canvasColor: Colors.transparent,
      ),
      home: Home()  //new HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
