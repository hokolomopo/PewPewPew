import 'dart:core';

import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/weaponry.dart';

class World{
  static final double gravity = 10;
  
  List<Character> players;
  List<Projectile> projectiles;

  //TODO terrain

  void updateWorld(){
  }

  void addPlayer(Character c){
    players.add(c);
  }

  void addProjectile(Projectile p){
    projectiles.add(p);
  }

}