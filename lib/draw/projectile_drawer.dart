import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/draw/assets_manager.dart';

import 'drawer_abstracts.dart';
import 'paint_constants.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/game/util/utils.dart';

class ProjectileDrawer extends ImagedDrawer {
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

    // Have to know if we have to rotate the image
    if (projectile.actualOrientation >= 0) {
      Image image = fetchNextFrame();

      if (image == null) return;
      canvas.save();

      Offset focalPoint = Offset(actualSize.width / 2, actualSize.height / 2);

      double x = left + actualSize.width / 2;
      double y = top + actualSize.height / 2;

      canvas.translate(x, y);

      // Update actualOrientationValue
      computeOrientation();
      canvas.rotate(projectile.actualOrientation);

      canvas.drawImage(image, focalPoint * -1, Paint());

      canvas.restore();
    } else
      canvas.drawImage(fetchNextFrame(), Offset(left, top), Paint());
  }

  void computeOrientation() {
    // If stopped don't modify anything
    if (!projectile.isMoving()) return;

    Offset speed = projectile.velocity;
    Offset ref = Offset(1, 0); // left to right vector Norm has to be 1

    if (speed.dy == 0) {
      if (speed.dx > 0) {
        projectile.actualOrientation = 0;
      } else {
        projectile.actualOrientation = pi;
      }
    }

    double cos = speed.dx * ref.dx + speed.dy * ref.dy;
    cos /= speed.distance; //ref.distance = 1

    if (speed.dy > 0)
      projectile.actualOrientation = acos(cos);
    else
      projectile.actualOrientation = 2*pi - acos(cos);
  }

  // For explosion purposes only
  @override
  void freezeAnimation({int frameNumber}) {
    if (gifInfo == null) return;

    if (frameNumber == null)
      gifInfo.freezeGif();
    else
      gifInfo.freezeGif(frameNumber: frameNumber);
  }

  @override
  void unfreezeAnimation() {
    if (gifInfo == null) return;

    gifInfo.unfreezeGif();
  }

  // For explosion purposes only
  @override
  void changeRelativeSize(Size size) {
    this.relativeSize = size;
  }
}

class ExplosionDrawer extends ImagedDrawer {
  Explosion explosion;

  ExplosionDrawer(AssetId assetId, this.explosion,
      {Size size = const Size(5, 5)})
      : super(size, assetId);

  @override
  void paint(
      Canvas canvas, Size screenSize, showHitBoxes, Offset cameraPosition) {
    if (explosion.animationEnded) return;

    if (gifInfo.curFrameIndex >= gifInfo.gif.length - 1) {
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
