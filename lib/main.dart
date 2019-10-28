import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/home.dart';
import 'package:info2051_2018/game/game_main.dart';

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
        primaryColor: Colors.red, // 0xFF80E1D1
        fontFamily: "Heroes",
        canvasColor: Colors.transparent,
      ),
      home: Home()  //new HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

//class HomePage extends StatefulWidget {
//  HomePage({Key key, this.title}) : super(key: key);
//
//  final String title;
//
//  @override
//  _HomePageState createState() => new _HomePageState();
//}
//
//class _HomePageState extends State<HomePage> {
//  int _counter = 0;
//
//  void _incrementCounter() {
//    setState(() {
//      _counter++;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      appBar: new AppBar(
//        title: new Text(widget.title),
//      ),
//      body: new Center(
//        child: new Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            new Text(
//              'You have pushed the button this many times:',
//            ),
//            new Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.display1,
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: new FloatingActionButton(
//        onPressed: () {
//          Navigator.push(
//            context,
//            MaterialPageRoute(builder: (context) => GameMain()),
//          );
//        },
//        tooltip: 'Increment',
//        child: new Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
//    );
//  }
//}
