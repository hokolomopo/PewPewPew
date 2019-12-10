import 'dart:ui';

import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/drawer_abstracts.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/weaponry.dart';

class WeaponDrawer extends ImagedDrawer {
  Weapon weapon;

  WeaponDrawer(AssetId id, this.weapon, Size relativeSize, int team)
      : super(relativeSize, id, team: team);

  @override
  void paint(
      Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition) {
    if (weapon.inSelection) {
      canvas.drawCircle(weapon.centerPos, Arsenal.selectionElementRadius,
          Paint()..color = Character.teamColors[team]);
    }

    canvas.drawImage(fetchNextFrame(), weapon.topLeftPos, Paint());
  }
}
