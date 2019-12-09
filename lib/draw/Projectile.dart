import 'dart:ui';

import 'package:info2051_2018/draw/assets_manager.dart';

import 'drawer_abstracts.dart';
import 'paint_constants.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/game/util/utils.dart';

// TODO Remove and Merge this with Draw Character File (maybe create a new abstract class ImagedCustomDrawer ?)

class ProjectileDrawer extends ImagedDrawer{
  Projectile projectile;

  ProjectileDrawer(AssetId assetId, this.projectile,
      {Size size = const Size(5, 5)})
      : super(size, assetId);

  @override
  void paint(
      Canvas canvas, Size screenSize, showHitBoxes, Offset cameraPosition) {
    double left = GameUtils.relativeToAbsoluteDist(
        projectile.position.dx, screenSize.height);
    double top = GameUtils.relativeToAbsoluteDist(
        projectile.position.dy, screenSize.height);

    if (showHitBoxes) {
      canvas.drawRect(
          Rect.fromLTWH(left, top, actualSize.width, actualSize.height),
          debugShowHitBoxesPaint);
    }

    // If frictionFactor == 1, we have to stay with the same frame
    if(projectile.animationStopped)
      gifInfo.lockAnimation = true;

      canvas.drawImage(fetchNextFrame(), Offset(left, top), Paint());
  }
}