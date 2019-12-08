import 'package:flutter/material.dart';
import 'package:info2051_2018/sound_player.dart';
import 'package:info2051_2018/quick_play.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'shop.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  SoundPlayer soundPlayer = SoundPlayer(false);
  final _menuMusicPath = "assets/sounds/menu/sample.mp3";
  final _menuMusicId = "sample.mp3";
  final _gameMusicPath = "assets/sounds/menu/sample2.mp3";
  final _gameMusicId = "sample2.mp3";

// Function for child to stop menu music
  void _stopMusic() {
    //soundPlayer.release();
    soundPlayer.playLocalAudio(_gameMusicPath, _gameMusicId, false);
  }

  void _reload() {
    Navigator.of(context).pop();
    soundPlayer.playLocalAudio(_menuMusicPath, _menuMusicId, false);
  }

  @override
  void initState() {
    super.initState();
    this
        .soundPlayer
        .playLocalAudio(_menuMusicPath, _menuMusicId, false);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    Color primary = Theme
        .of(context)
        .primaryColor;

    // Play music in background (loop) if home page main rendered rendered
    if (ModalRoute.of(context).isCurrent)
      this.soundPlayer.playLocalAudio("assets/sounds/menu/sample.mp3", 'sample.mp3', false);




    // logo widget
    Widget logo() {
      return Padding(
        padding:
        EdgeInsets.only(top: MediaQuery
            .of(context)
            .size
            .height * 0.15),
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: 220.0,
          child: Stack(
            children: <Widget>[
              Positioned(
                  child: Container(
                    child: Align(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(20.0),
                          color: Colors.blueAccent,
                          border: new Border.all(color: Colors.white70,
                              width: 5.0),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.black,
                              blurRadius: 3.0,
                            )
                          ],
                        ),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.80,
                        height: MediaQuery
                            .of(context)
                            .size
                            .width * 0.2,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            "Pew Pew Pew !!!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Birdy',
                            ),
                          ),
                        ),
                      ),
                    ),
                    height: 154.0,
                  )),
            ],
          ),
        ),
      );
    }

    //button widget
    Widget _button(String text, Color splashColor, Color highlightColor,
        Color fillColor, Color textColor, num borderRadius, void function()) {
      return RaisedButton(
        highlightElevation: 10.0,
        splashColor: splashColor,
        highlightColor: highlightColor,
        elevation: 0.0,
        color: fillColor,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(borderRadius)),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(text,
              style: TextStyle(
                  height: 1.7,
                  fontWeight: FontWeight.normal,
                  color: textColor,
                  fontSize: 20.0)),
        ),
        onPressed: () {
          function();
        },
      );
    }

    void _tutorialConfirm(String title, String mess, String neg, String pos) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(title),
            content: new Text(mess),
            actions: <Widget>[
              new FlatButton(
                // Negative choice button
                child: new Text(
                  neg,
                  style: new TextStyle(fontWeight: FontWeight.normal),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                // Positive choice button
                child: new Text(
                  pos,
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void _parameters() {
      _scaffoldKey.currentState.showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme
              .of(context)
              .canvasColor),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 10.0,
                          top: 10.0,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.close,
                              size: 30.0,
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    height: 50.0,
                    width: 50.0,
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 140.0,
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                child: Align(
                                  child: Container(
                                    width: 130.0,
                                    height: 130.0,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme
                                            .of(context)
                                            .primaryColor),
                                  ),
                                  alignment: Alignment.center,
                                ),
                              ),
                              Positioned(
                                child: Container(
                                  child: Text(
                                    "PLAY",
                                    style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Parameters(
                          parentAction: _stopMusic,
                          reloadHome: _reload
                        )
                      ],
                    ),
                  ),
                ],
              ),
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 1.05, // / 1.1
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    // Function to be pass to a future builder in order
    // to pass variables to the shop list builder
    Future<Set> getShopInfo() async {
      Set ret = Set();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      //await prefs.clear(); // Debug line to reset the entire app preference

      var tmp = await DefaultAssetBundle.of(context)
          .loadString('assets/data/shop/items.json');

      List<Item> items = parseJson(tmp.toString());
      ret.add(items);
      ret.add(prefs);
      return ret;
    }

    void _shopSheet() {
      _scaffoldKey.currentState.showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme
              .of(context)
              .canvasColor),
          child: ClipRect(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 10.0,
                          top: 10.0,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.close,
                              size: 30.0,
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    height: 50.0,
                    width: 50.0,
                  ),
                  Expanded(
                    child: new FutureBuilder(
                        future: getShopInfo(),
                        builder: (context, snapshot) {
                          List<Item> items;
                          SharedPreferences prefs;
                          if (snapshot.data != null) {
                            items = snapshot.data.elementAt(0);
                            prefs = snapshot.data.elementAt(1);
                          }

                          return (items != null && prefs != null)
                              ? new ShopList(items: items, prefs: prefs)
                              : new Center(
                            child: new CircularProgressIndicator(),
                          );
                        }),
                  ),
                ],
              ),
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    return Stack(
      children: <Widget>[
        Image.asset(
          "assets/graphics/backgrounds/menu-background3.jpg",
          height: MediaQuery
              .of(context)
              .size
              .height,
          width: MediaQuery
              .of(context)
              .size
              .width,
          fit: BoxFit.cover,
        ),
        Scaffold(
            resizeToAvoidBottomPadding: false,
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
            body: Column(
              children: <Widget>[
                logo(),
                Padding(
                  child: Container(
                    child: _button(
                        "Quick Play",
                        primary,
                        Colors.white,
                        Colors.white,
                        primary,
                        30.0,
                        _parameters),
                    height: 50.0,
                  ),
                  padding: EdgeInsets.only(top: 80.0, left: 20.0, right: 20.0),
                ),
                Padding(
                  child: Container(
                    child: _button(
                        "Tutorial",
                        primary,
                        Colors.white,
                        Colors.white,
                        primary,
                        30.0, () {
                      _tutorialConfirm(
                          "Start tutorial?",
                          "The tutorial is recommanded for new players",
                          "Cancel",
                          "Start");
                    }),
                    height: 50.0,
                  ),
                  padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                ),
                Padding(
                  child: Container(
                    child: _button(
                        "Shop",
                        primary,
                        Colors.white,
                        Colors.white,
                        primary,
                        30.0,
                        _shopSheet),
                    height: 50.0,
                  ),
                  padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ))
      ],
    );
  }

  @override
  void dispose() {
    soundPlayer.release();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state) {
      case AppLifecycleState.resumed:
        soundPlayer.resume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        soundPlayer.pause();
        break;
    }
  }
}
