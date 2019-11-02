import 'dart:ui';

import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/terrain.dart';
import 'package:info2051_2018/game/world.dart';

enum GameStateMode{char_selection, moving, attacking, cinematic}

class GameState{
  GameStateMode state = GameStateMode.char_selection;

  List<List<Character>> players = new List();
  int currentPlayer = 0;
  int currentCharacter = 0;

  World world = new World();

  GameState(int numberOfPlayers, int numberOfCharacters){
    //TODO load level
    world.addTerrain(new Terrain(0, 200, 20000, 10));
    world.addTerrain(new Terrain(400, 0, 10, 20000));

    for(int i = 0;i < numberOfPlayers;i++) {

      List<Character> chars = new List();
      players.add(chars);

      for (int j = 0; j < numberOfCharacters; j++) {

        //TODO how to place characters
        Character c = new Character(new Offset(10, 10));
        chars.add(c);
        world.addPlayer(c);

        //TODO delete dis
        c.velocity = new Offset(1, 1);

      }
    }

  }

  void update(){
    world.updateWorld();
  }

  Character getCurrentCharacter(){
    return players[currentPlayer][currentCharacter];
  }
}