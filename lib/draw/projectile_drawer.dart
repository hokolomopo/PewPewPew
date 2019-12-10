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
        projectile.getSpritePosition().dx, screenSize.height);
    double top = GameUtils.relativeToAbsoluteDist(
        projectile.getSpritePosition().dy, screenSize.height);

    if (showHitBoxes) {
      canvas.drawRect(
          Rect.fromLTWH(left, top, actualSize.width, actualSize.height),
          debugShowHitBoxesPaint);
    }

      canvas.drawImage(fetchNextFrame(), Offset(left, top), Paint());
  }

  // For explosion purposes only
  @override
  void freezeAnimation({int frameNumber}){
    if (gifInfo == null)
      return;

    if (frameNumber == null)
      gifInfo.freezeGif();
    else
      gifInfo.freezeGif(frameNumber: frameNumber);
  }

  @override
  void unfreezeAnimation(){
    if (gifInfo == null)
      return;

    gifInfo.unfreezeGif();
  }

  // For explosion purposes only
  @override
  void changeRelativeSize(Size size){
    this.relativeSize = size;
  }
}


class ExplosionDrawer extends ImagedDrawer{
  Explosion explosion;

  ExplosionDrawer(AssetId assetId, this.explosion,
      {Size size = const Size(5, 5)})
      : super(size, assetId);

  @override
  void paint(
      Canvas canvas, Size screenSize, showHitBoxes, Offset cameraPosition) {

    if(explosion.animationEnded)
      return;

    if(gifInfo.curFrameIndex >= gifInfo.gif.length - 1){
      explosion.animationEnded = true;
    }

    double left = GameUtils.relativeToAbsoluteDist(
        explosion.getSpritePosition().dx, screenSize.height);
    double top = GameUtils.relativeToAbsoluteDist(
        explosion.getSpritePosition().dy, screenSize.height);

    if (showHitBoxes) {
      canvas.drawRect(
          Rect.fromLTWH(left, top, actualSize.width, actualSize.height),
          debugShowHitBoxesPaint);
    }


    canvas.drawImage(fetchNextFrame(), Offset(left, top), Paint());


  }
}