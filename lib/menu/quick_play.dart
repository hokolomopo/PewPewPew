import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/main.dart';
import 'dart:convert'; // json codec
import 'package:info2051_2018/menu/quickplay_widgets.dart';
import 'package:info2051_2018/sound_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/game_main.dart';
import 'route_arguments.dart';

class Parameters extends StatefulWidget {

  const Parameters({Key key}) : super(key: key);

  @override
  ParametersState createState() => ParametersState();
}

class ParametersState extends State<Parameters> {
  int _nbPlayer = 2; // nb of player in game
  int _nbWorms = 1; // nb of Worms per team
  Terrain _terrain; // identification of the selected map to instantiate
  List<WeaponStats> _availableWeapons;

  ParametersState();

  @override
  Widget build(BuildContext context) {
    return _parameter(context);
  }

  void _handleNbPlayers(int value) {
    setState(() {
      _nbPlayer = value;
    });
  }

  void _handleNbWorms(int value) {
    setState(() {
      _nbWorms = value;
    });
  }

  void _selectTerrain(Terrain value) {
    setState(() {
      _terrain = value;
    });
  }

  List<Terrain> parseJson(String response) {
    if (response == "null") {
      // If the future reading operation is not done yet (connection waiting with initial data)
      return [];
    }
    final parsed =
        json.decode(response.toString()).cast<Map<String, dynamic>>();
    return parsed.map<Terrain>((json) => new Terrain.fromJson(json)).toList();
  }

  // Function to retrieve info on terrain in order
  // to pass it to the future builder
  Future<List<Terrain>> getTerrainInfo() async {
    var tmp = await DefaultAssetBundle.of(context)
        .loadString('assets/data/quickplay/terrains.json');

    return parseJson(tmp.toString());
  }

  // Function to retrieve info on weapons in order
  // to pass it to the game
  void _getWeaponsInfo() async {
    _availableWeapons = await PewPewPew.weaponsInfo;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<WeaponStats> toRemove = List();
    for (WeaponStats weapon in _availableWeapons) {
      if (!prefs.containsKey(weapon.weaponName)) {
        toRemove.add(weapon);
      }
    }
    _availableWeapons
        .removeWhere((WeaponStats weapon) => toRemove.contains(weapon));
  }

  List<Widget> buildRadioList(
      {String title,
      List<String> texts,
      List<Color> colors,
      int groupValue,
      Function onChanged,
      List<int> values}) {
    List<Widget> list = List();
    list.add(
        Expanded(child: FittedBox(fit: BoxFit.contain, child: Text(title))));

    for (int i = 0; i < texts.length; i++) {
      list.add(Expanded(
          child: Column(children: <Widget>[
        Text(texts[i]),
        Radio(
          activeColor: colors[i],
          value: values == null ? i + 1 : values[i],
          groupValue: groupValue,
          onChanged: onChanged,
        )
      ])));
    }
    return list;
  }

  Widget _parameter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
          child: Row(
              children: buildRadioList(
                  title: "Number\nPlayers",
                  texts: ["2P", "3P", "4P"],
                  colors: [
                    Colors.lightBlueAccent,
                    Colors.green,
                    Colors.deepPurpleAccent
                  ],
                  groupValue: _nbPlayer,
                  values: [2, 3, 4],
                  onChanged: _handleNbPlayers)),
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
            child: Row(
                children: buildRadioList(
                    title: "Number\nWorms",
                    texts: ["1", "2", "3", "4"],
                    colors: [
                      Colors.redAccent,
                      Colors.lightBlueAccent,
                      Colors.green,
                      Colors.deepPurpleAccent
                    ],
                    groupValue: _nbWorms,
                    onChanged: _handleNbWorms))),
        SizedBox(
          height: 20.0,
        ),
        Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder(
            future: getTerrainInfo(),
            builder: (context, snapshot) {
              return (snapshot.data != null)
                  ? TerrainScrollableList(
                      snapshot.data,
                      selectedTerrain: _terrain,
                      onTap: _selectTerrain,
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 60.0),
          child: Container(
            child: RaisedButton(
              highlightElevation: 10.0,
              splashColor: Colors.white,
              highlightColor: Theme.of(context).primaryColor,
              elevation: 0.0,
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text("GO !",
                    style: TextStyle(
                        height: 1.7,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 20.0)),
              ),
              onPressed: () {
                Size screenSize = MediaQuery.of(context).size;
                GameMain.size = Size(max(screenSize.width, screenSize.height), min(screenSize.width, screenSize.height));

                if (_terrain == null)
                  _simpleAlertDialog("Please select a level", context);
                else {
                  SoundPlayer.getInstance().playLoopMusic(SoundPlayer.gameMusicName, volume: 0.5);
                  Navigator.pushNamedAndRemoveUntil(context, GameMain.routeName,
                      (Route<dynamic> route) => false,
                      arguments: MainGameArguments(_terrain, _nbPlayer,
                          _nbWorms, this._availableWeapons));
                }
              },
            ),
            height: 50.0,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        Padding(padding: EdgeInsets.only(bottom: 3.0),)
      ],
    );
  }

  /// Simple Alert dialog
  void _simpleAlertDialog(String text, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text(
            text,
            style: TextStyle(height: 1.5, color: Colors.black),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getWeaponsInfo();
  }
}
