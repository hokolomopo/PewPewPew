import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/terrain.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // To counter Flutter update inconvenient
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(new PewPewPew());
  });
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
        primaryColor: Colors.red,
        // 0xFF80E1D1
        fontFamily: "Heroes",
        canvasColor: Colors.transparent,
      ),
      home: DrawTest(), //new HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class DrawTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawTestState();
}

class _DrawTestState extends State<DrawTest> {
  TerrainDrawer terrainDrawer = TerrainDrawer();

  @override
  void initState() {
    super.initState();
    terrainDrawer.createTerrainFromFunction(
        (left) => ((sin(left * 4 * pi) + 2) / 10),
        nbBlocks: 1000);
    terrainDrawer.addTerrainBlock(Offset(0.3, 0.5), width: 0.2, height: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GestureDetector(onTap: _testTap, child: terrainDrawer.terrain),
      ),
    );
  }

  _testTap() {
    Set<Offset> set = Set();
    set.add(Offset(0.3, 0.5));
    setState(() {
      terrainDrawer.removeBlocksByPositions(set);
      terrainDrawer.removeBlocksInRange(Offset(0.5, 0.8), 0.05);
    });
  }
}
