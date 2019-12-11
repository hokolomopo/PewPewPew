
import 'package:info2051_2018/quickplay_widgets.dart';

import 'game/weaponry.dart';

class MainGameArguments{
  final int nbPlayers;
  final int nbCharacters;
  final Terrain terrain;
  final List<WeaponStats> weaponStats;

  MainGameArguments(this.terrain, this.nbPlayers, this.nbCharacters, this.weaponStats);
}