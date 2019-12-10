import 'dart:ui';

import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/drawer_abstracts.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/weaponry.dart';

class WeaponDrawer extends ImagedDrawer {
  Weapon weapon;
  Color teamColor;

  WeaponDrawer(AssetId id, this.weapon, Size relativeSize, Color teamColor)
      : super(relativeSize, id){
    if(teamColor == null)
      print("wtf");
  }

  @override
  void paint(
      Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition) {
    if (weapon.inSelection) {
      //TODO why the fuck is teamcolor null
      if(teamColor != null)
        canvas.drawCircle(weapon.centerPos, Arsenal.selectionElementRadius,
            Paint()..color = teamColor);
    }

    canvas.drawImage(fetchNextFrame(), weapon.topLeftPos, Paint());
  }
}
