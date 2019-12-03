import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // json codec
import 'package:info2051_2018/game/sound_player.dart';

import 'game/game_main.dart';

class Terrain {
  final String name;
  final String imgName;
  String levelObject;

  Terrain({this.name, this.imgName, this.levelObject});

  factory Terrain.fromJson(Map<String, dynamic> json) {
    return new Terrain(
      name: json['name'] as String,
      imgName: json['imgName'] as String,
      levelObject: json['levelObject'] as String,
    );
  }
}

class Parameters extends StatefulWidget {
  final void Function() parentAction;

  const Parameters({Key key, this.parentAction}) : super(key: key);

  @override
  ParametersState createState() {
    return new ParametersState();
  }
}

class ParametersState extends State<Parameters> {
  int _nbPlayer = 0; // nb of player in game
  int _nbWorms = 0; // nb of Worms per team
  Terrain _terrain; // identification of the selected map to instantiate

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


  void _handleTerrain(Terrain value) {
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

  Widget customTerrainRadioList(List<Terrain> terrains) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 200.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: terrains == null ? 0 : terrains.length,
          itemBuilder: (context, index) {
            return customTerrainRadio(terrains[index]);
          },
        ),
      ),
    );
  }

  Widget customTerrainRadio(Terrain terrain) {
    if (_terrain != null && terrain.name == _terrain.name)
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 3.0),
            image: DecorationImage(
              image:
                  AssetImage('assets/graphics/backgrounds/' + terrain.imgName),
              fit: BoxFit.fill,
            )),
        child: InkWell(
          onTap: () {
            _handleTerrain(terrain);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: AutoSizeText(
                      terrain.name,
                      maxLines: 1,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    else
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/graphics/backgrounds/' + terrain.imgName),
          fit: BoxFit.fill,
        )),
        child: InkWell(
          onTap: () {
            _handleTerrain(terrain);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: AutoSizeText(
                      terrain.name,
                      maxLines: 1,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
  }

  Widget _parameter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 10.0, top: 20.0),
          child: Row(children: <Widget>[
            Expanded(
                child: FittedBox(
                    fit: BoxFit.contain, child: Text("Number\nPlayers"))),
            Expanded(
                child: Column(children: <Widget>[
              Text("1P"),
              Radio(
                activeColor: Colors.redAccent,
                value: 1,
                groupValue: _nbPlayer,
                onChanged: _handleNbPlayers,
              )
            ])),
            Expanded(
                child: Column(children: <Widget>[
              Text("2P"),
              Radio(
                activeColor: Colors.lightBlueAccent,
                value: 2,
                groupValue: _nbPlayer,
                onChanged: _handleNbPlayers,
              )
            ])),
            Expanded(
                child: Column(children: <Widget>[
              Text("3P"),
              Radio(
                activeColor: Colors.green,
                value: 3,
                groupValue: _nbPlayer,
                onChanged: _handleNbPlayers,
              )
            ])),
            Expanded(
                child: Column(children: <Widget>[
              Text("4P"),
              Radio(
                activeColor: Colors.deepPurpleAccent,
                value: 4,
                groupValue: _nbPlayer,
                onChanged: _handleNbPlayers,
              )
            ]))
          ]),
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
            child: Row(children: <Widget>[
              Expanded(
                  child: FittedBox(
                      fit: BoxFit.contain, child: Text("Number\nWorms"))),
              Expanded(
                  child: Column(children: <Widget>[
                Text("1"),
                Radio(
                  activeColor: Colors.redAccent,
                  value: 1,
                  groupValue: _nbWorms,
                  onChanged: _handleNbWorms,
                )
              ])),
              Expanded(
                  child: Column(children: <Widget>[
                Text("2"),
                Radio(
                  activeColor: Colors.lightBlueAccent,
                  value: 2,
                  groupValue: _nbWorms,
                  onChanged: _handleNbWorms,
                )
              ])),
              Expanded(
                  child: Column(children: <Widget>[
                Text("3"),
                Radio(
                  activeColor: Colors.green,
                  value: 3,
                  groupValue: _nbWorms,
                  onChanged: _handleNbWorms,
                )
              ])),
              Expanded(
                  child: Column(children: <Widget>[
                Text("4"),
                Radio(
                  activeColor: Colors.deepPurpleAccent,
                  value: 4,
                  groupValue: _nbWorms,
                  onChanged: _handleNbWorms,
                )
              ]))
            ])),
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
                  ? customTerrainRadioList(snapshot.data)
                  : Center(
                      child: CircularProgressIndicator(),
                    );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 10.0,
              bottom: MediaQuery.of(context).viewInsets.bottom),
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
                widget.parentAction();
                //SoundPlayer ap = widget.createElement().ancestorWidgetOfExactType(SoundPlayer);
                //ap.pause();

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameMain(level:_terrain.levelObject)),
                );
              },
            ),
            height: 50.0,
            width: MediaQuery.of(context).size.width,
          ),
        ),
      ],
    );
  }
}
