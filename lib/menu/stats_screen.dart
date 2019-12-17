import 'dart:async';

import 'package:flutter/material.dart';
import 'package:info2051_2018/game/util/game_statistics.dart';
import 'package:info2051_2018/menu/home.dart';
import 'package:info2051_2018/sound_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/util/team.dart';
import 'shop.dart';

import 'dart:math';

class StatsScreen extends StatefulWidget {
  static const routeName = '/Stats';

  final GameStats gameStats;

  StatsScreen(this.gameStats);

  @override
  _StatsScreenState createState() => _StatsScreenState(gameStats);
}

class _StatsScreenState extends State<StatsScreen> with WidgetsBindingObserver {
  static const Map<TeamStat, double> _moneyByStat = {
    TeamStat.damage_dealt: 10,
    TeamStat.damage_taken: -0.5,
    TeamStat.alive: 300,
    TeamStat.killed: 500,
    TeamStat.self_killed: -200,
    TeamStat.damage_self_dealt: -1,
  };

  int totalMoneyGain;

  _StatsScreenState(GameStats stats) {

    // If no one wins, a random team wins :
    if(stats.statistics[stats.winningTeam] == null)
      stats.winningTeam = stats.statistics.keys.toList()[0];

    totalMoneyGain = 0;
    for (TeamStat stat in TeamStat.values)
      totalMoneyGain +=
          (_moneyByStat[stat] * stats.statistics[stats.winningTeam][stat]).floor();
    totalMoneyGain = max(0, totalMoneyGain);

    saveMoney();
  }

  void saveMoney() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int currentMoney = 0;
    if (prefs.containsKey(ShopList.moneySharedPrefKey))
      currentMoney = prefs.getInt(ShopList.moneySharedPrefKey);
    prefs.setInt(ShopList.moneySharedPrefKey, currentMoney + totalMoneyGain);
  }


  @override
  void initState() {
    super.initState();
    SoundPlayer.getInstance().playLoopMusic(SoundPlayer.menuMusicName, volume: 1.0);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    //Wait for the app to be in portrait mode
    if (mediaQueryData.orientation == Orientation.landscape)
      return Container();


    //button widget
    Widget continueButton() {
      return RaisedButton(
        highlightElevation: 10.0,
        splashColor: Colors.black12,
        highlightColor: Colors.white,
        elevation: 3.0,
        color: Colors.blue[200],
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
          side: BorderSide(
            width: 1.0,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text("Continue",
              style: TextStyle(
                  height: 1.7,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontSize: 20.0)),
        ),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
              context, Home.routeName, (Route<dynamic> route) => false);
        },
      );
    }

    Widget buildTextRow({TeamStat stat, divider: true}) {
      String msg;
      switch (stat) {
        case TeamStat.damage_dealt:
          msg = "Damage dealt : ";
          break;
        case TeamStat.damage_self_dealt:
          msg = "Dmg self-inficted : ";
          break;
        case TeamStat.killed:
          msg = "Ennemies killed : ";
          break;
        case TeamStat.self_killed:
          msg = "Suicides : ";
          break;
        case TeamStat.alive:
          msg = "Remaining characters : ";
          break;
        case TeamStat.damage_taken:
          msg = "Damage taken : ";
          break;
      }

      int curStat = widget.gameStats
          .statistics[widget.gameStats.winningTeam][stat].floor();

      return Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    msg +
                        curStat
                            .toString(),
                    style: TextStyle(
                        fontSize: 10, color: Colors.black.withOpacity(0.5)),
                  ),
                  Text(
                    (_moneyByStat[stat] *
                                curStat).toStringAsFixed(0)
                            +
                        "\$",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  )
                ],
              ),
            ),
            divider
                ? Divider(color: Colors.black.withOpacity(0.3))
                : SizedBox.shrink()
          ],
        ),
      );
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _exit,
      child: Stack(
          children: <Widget>[
            Image.asset(
              "assets/graphics/backgrounds/menu-background3.jpg",
              height: screenHeight,
              width: screenWidth,
              fit: BoxFit.cover,
            ),
            Scaffold(
              body: Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight / 15, left: 30.0, right: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      SizedBox(
                        height: screenHeight * 0.7,
                        child: DecoratedBox(
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                                side: BorderSide(
                                  width: 1.0,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                              gradient: RadialGradient(
                                  colors: [Colors.blue[200], Colors.blue[300]]),
                              shadows: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: Offset(2, 4),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 1.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(
                                    "Winning Team : \n Team " +
                                        widget.gameStats.winningTeam,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        height: 1.5),
                                  ),
                                  Divider(
                                    color: Colors.black.withOpacity(0.6),
                                    height: 30.0,
                                    thickness: 3.0,
                                  ),
                                  buildTextRow(stat: TeamStat.damage_dealt),
                                  buildTextRow(stat: TeamStat.damage_self_dealt),
                                  buildTextRow(stat: TeamStat.damage_taken),
                                  buildTextRow(stat: TeamStat.killed),
                                  buildTextRow(stat: TeamStat.self_killed),
                                  buildTextRow(
                                      stat: TeamStat.alive, divider: false),
                                  Divider(
                                    color: Colors.black.withOpacity(0.5),
                                    height: 20.0,
                                    thickness: 3.0,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 10.0),
                                      child: Center(
                                        child: Text(
                                          "Total : " +
                                              totalMoneyGain.toString() +
                                              "\$",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              height: 1.5),
                                        ),
                                      ))
                                ],
                              ),
                            )),
                      ),
                      continueButton(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                      )
                    ],
                  )),
            )
          ],
        ),
    );
  }

  Future<bool> _exit() async{
    Navigator.pushNamedAndRemoveUntil(
        context, Home.routeName, (Route<dynamic> route) => false);
    return false;
  }

  @override
  void dispose() {
//    soundPlayer.release();
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
      case AppLifecycleState.suspending:
        SoundPlayer.getInstance().pauseLoopMusic();
        break;
    }
  }
}
