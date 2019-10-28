
import 'package:flutter/material.dart';

class Parameters extends StatefulWidget {
  @override
  ParametersState createState() {
    return new ParametersState();
  }
}

class ParametersState extends State<Parameters>{
  var _nbPlayer = 0; // nb of player in game
  var _nbWorms = 0; // nb of Worms per team
  var _map = 0; // identification of the selected map to instantiate

  @override
  Widget build(BuildContext context) {
    return _parameter(context);
  }

  void _handleNbPlayersRadio(int value) {
    setState(() {
      _nbPlayer = value;
    });
  }

  void _handleNbWorms(int value) {
    setState(() {
      _nbWorms = value;
    });
  }

  Widget _parameter(BuildContext context){
    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.only(bottom: 10, top: 20),
        child: Row(children: <Widget>[
          Expanded(child: FittedBox(fit: BoxFit.contain, child: Text("Number\nPlayers"))),
          Expanded(child: Column(children: <Widget>[Text("1P"), Radio(activeColor: Colors.redAccent, value: 1, groupValue: _nbPlayer, onChanged: _handleNbPlayersRadio,)])),
          Expanded(child: Column(children: <Widget>[Text("2P"), Radio(activeColor: Colors.lightBlueAccent, value: 2, groupValue: _nbPlayer, onChanged: _handleNbPlayersRadio,)])),
          Expanded(child: Column(children: <Widget>[Text("3P"), Radio(activeColor: Colors.green, value: 3, groupValue: _nbPlayer, onChanged: _handleNbPlayersRadio,)])),
          Expanded(child: Column(children: <Widget>[Text("4P"), Radio(activeColor: Colors.deepPurpleAccent, value: 4, groupValue: _nbPlayer, onChanged: _handleNbPlayersRadio,)]))
        ]),
      ),

      Padding(
          padding: EdgeInsets.only(bottom: 10, top: 10),
          child: Row(children: <Widget>[
            Expanded(child: FittedBox(fit: BoxFit.contain, child: Text("Number\nWorms"))),
            Expanded(child: Column(children: <Widget>[Text("1"), Radio(activeColor: Colors.redAccent, value: 1, groupValue: _nbWorms, onChanged: _handleNbWorms,)])),
            Expanded(child: Column(children: <Widget>[Text("2"), Radio(activeColor: Colors.lightBlueAccent, value: 2, groupValue: _nbWorms, onChanged: _handleNbWorms,)])),
            Expanded(child: Column(children: <Widget>[Text("3"), Radio(activeColor: Colors.green, value: 3, groupValue: _nbWorms, onChanged: _handleNbWorms,)])),
            Expanded(child: Column(children: <Widget>[Text("4"), Radio(activeColor: Colors.deepPurpleAccent, value: 4, groupValue: _nbWorms, onChanged: _handleNbWorms,)]))
          ])
      ),
      SizedBox(
        height: 20.0,
      ),
      Padding(
        padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          child: RaisedButton(
            highlightElevation: 10.0,
            splashColor: Theme.of(context).primaryColor,
            highlightColor: Theme.of(context).primaryColor,
            elevation: 0.0,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30)),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                  "GO !",
                  style: TextStyle(
                      height: 1.7,
                      fontWeight: FontWeight.normal, color: Colors.white, fontSize: 20)
              ),),
            onPressed: () {
              () {};
            },
          ),
          height: 50.0,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    ],);
  }

}








