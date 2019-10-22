import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/world.dart';

enum GameStateMode{char_selection, moving, attacking, cinematic}

class GameState{
  GameStateMode state = GameStateMode.char_selection;

  List<Character> players;
  World world = new World();
}