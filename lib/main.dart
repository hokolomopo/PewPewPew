import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/util/game_statistics.dart';
import 'package:info2051_2018/home.dart';
import 'package:info2051_2018/stats_screen.dart';

import 'route_arguments.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // To counter Flutter update inconvenient
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]); // t
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
      onGenerateRoute: (settings) {

      // Game screen
      if(settings.name == GameMain.routeName){
        final MainGameArguments args = settings.arguments;
        return MaterialPageRoute(
          builder: (context) {
            return GameMain(args.terrain, args.nbPlayers, args.nbCharacters);
          },
        );
      }

      // Statistics screen
      if(settings.name == StatsScreen.routeName){
        final GameStats stats = settings.arguments;
        return MaterialPageRoute(
          builder: (context) {
            return StatsScreen(stats);
          },
        );
      }

      if(settings.name == Home.routeName || settings.isInitialRoute){
        return MaterialPageRoute(
          builder: (context) {
            return Home();
          },
        );
      }

      return null;
    },
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Color(0xFFC0F0E8),
        primaryColor: Colors.lightBlue, // 0xFF80E1D1
        fontFamily: "Heroes",
        canvasColor: Colors.transparent,
      ),
    );
  }
}