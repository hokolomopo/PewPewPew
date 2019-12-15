import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/main.dart';
import 'package:info2051_2018/sound_player.dart';
import 'package:info2051_2018/menu/quick_play.dart';
import 'package:info2051_2018/menu/tutoriel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shop.dart';

class Home extends StatefulWidget {
  static const routeName = '/Home';

  static Size _screenSize;
  static bool sizeLocked = false;

  static double _musicVolume = 1.0;
  static double _SFXVolume = 1.0;

  static double get musicVolume {
    return _musicVolume;
  }

  static double get sfxVolume {
    return _SFXVolume;
  }

  static set screenSize(Size newSize) {
    if (!sizeLocked) _screenSize = newSize;
  }

  static Size get screenSizeLandscape {
    return Size(_screenSize.height, _screenSize.width);
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();


// Function for child to stop menu music

  @override
  void initState() {
    super.initState();
    SoundPlayer.getInstance().playLoopMusic(SoundPlayer.menuMusicName, volume: 1.0);
    WidgetsBinding.instance.addObserver(this);
    _addDefaultWeapons();
  }

  @override
  Widget build(BuildContext context) {
    Home.screenSize = MediaQuery.of(context).size;
    Color primary = Theme.of(context).primaryColor;

    // logo widget
    Widget logo() {
      return Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
        child: Container(
          width: MediaQuery.of(context).size.width,
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
                        border:
                            new Border.all(color: Colors.white70, width: 5.0),
                        boxShadow: [
                          new BoxShadow(
                            color: Colors.black,
                            blurRadius: 3.0,
                          )
                        ],
                      ),
                      width: MediaQuery.of(context).size.width * 0.80,
                      height: MediaQuery.of(context).size.width * 0.2,
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
                ),
              ),
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

    void _parameters() {
      Home.sizeLocked = true;
      _scaffoldKey.currentState.showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
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
                              color: Theme.of(context).primaryColor,
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
                          width: MediaQuery.of(context).size.width,
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
                                        color: Theme.of(context).primaryColor),
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
                        Parameters(),
                      ],
                    ),
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height / 1.05, // / 1.1
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    void _shopSheet() {
      _scaffoldKey.currentState.showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          child: ClipRect(
            child: Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ShopList(),
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
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
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
            resizeToAvoidBottomPadding: false,
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
            body: Column(
              children: <Widget>[

                Padding(
                    padding: EdgeInsets.only(top: 20.0 ,bottom: 20.0),
                    child : Container(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            callSlider();
                          },
                          icon: Icon(
                            Icons.volume_up,
                            size: 30.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ),



                logo(),
                Padding(
                  child: Container(
                    child: _button("Quick Play", primary, Colors.white,
                        Colors.white, primary, 30.0, _parameters),
                    height: 50.0,
                  ),
                  padding: EdgeInsets.only(top: 80.0, left: 20.0, right: 20.0),
                ),
                Padding(
                  child: Container(
                    child: _button("Tutorial", primary, Colors.white,
                        Colors.white, primary, 30.0, () {
                          showDialog(
                              context: context,
                              builder: (_) => TutorialWidget()
                          );
                        }),
                    height: 50.0,
                  ),
                  padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                ),
                Padding(
                  child: Container(
                    child: _button("Shop", primary, Colors.white, Colors.white,
                        primary, 30.0, _shopSheet),
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

  _addDefaultWeapons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<WeaponStats> weapons = await PewPewPew.weaponsInfo;
    for (WeaponStats weapon in weapons) {
      if (weapon.price == 0) {
        prefs.setInt(weapon.weaponName, 0);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        SoundPlayer.getInstance().resumeLoopMusic();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        SoundPlayer.getInstance().pauseLoopMusic();
        break;
        break;
    }
  }


  void callSlider() {
    showDialog(
        context: context,
        builder: (_) =>
            Scaffold(
                body: Center(child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.white,
                  ),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10.0, top: 10.0, bottom: 10.0),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: BackButton(
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 50,
                          child: Column(children: <Widget>[
                            AutoSizeText("Musique Volume"),
                            VolumeSlider(isMusic: true),

                          ],),
                        ),
                        Expanded(
                          flex: 50,
                          child: Column(
                            children: <Widget>[
                              AutoSizeText("SFX Volume"),
                              VolumeSlider(isMusic: false),
                            ],
                          ),
                        )
                      ],
                    ),
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.4,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.8,
                    color: Colors.white,
                  ),
                ),)

            ));





  }

}

class VolumeSlider extends StatefulWidget{

  final bool isMusic;

  const VolumeSlider({Key key, this.isMusic}): super(key : key);

  @override
  VolumeSliderState createState() => VolumeSliderState();
}

class VolumeSliderState extends State<VolumeSlider>{

  double value;

  @override
  Widget build(BuildContext context){

    if(widget.isMusic)
      value = Home._musicVolume;
    else
      value = Home._SFXVolume;

    return Slider(
      min: 0.0,
      max: 1.0,
      value: value,
      onChanged:
      (d){
        setState(() {
          value = d;
          SoundPlayer soundPlayer = SoundPlayer.getInstance();
          if(widget.isMusic) {
            Home._musicVolume = d;
            soundPlayer.musicVolumeScale = value;
          }
          else{
            Home._SFXVolume = d;
            soundPlayer.sfxVolumeScale = value;
          }
        });
      }
      ,
    );
  }

}
