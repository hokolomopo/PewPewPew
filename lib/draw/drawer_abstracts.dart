import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'assets_manager.dart';

/// Class to draw image. We consider that a png is a gif with only one image
abstract class ImagedDrawer extends CustomDrawer {
  AssetId assetId;
  AssetsManager assetsManager;
  GifInfo gifInfo;
  bool changeGif = true;

  double angle = 0;

  set relativeSize(Size newSize) {
    if (newSize != _relativeSize) {
      _relativeSize = newSize;
      gifInfo = null;
    }
  }

  get relativeSize => _relativeSize;

  // For team specific assets
  int team;

  ImagedDrawer(Size relativeSize, this.assetId, {this.team})
      : super(relativeSize);

  @override
  bool isReady(Size screenSize) {
    super.isReady(screenSize);

    // Check if the asset is loaded
    bool isAssetLoaded =
        assetsManager.isAssetLoaded(assetId, _relativeSize, team: team);

    if (isAssetLoaded) {
      if (gifInfo == null) {
        gifInfo = assetsManager.getGifInfo(assetId, _relativeSize, team: team);
      }
      return fetchNextFrame() != null;
    }
    return false;
  }

  /// Fetch the next frame of the gif
  ui.Image fetchNextFrame() {
    return gifInfo.fetchNextFrame();
  }

  set gif(AssetId newGifId) {
    assetId = newGifId;
    gifInfo = null;
  }

  drawImage(Canvas canvas, ui.Image image, Offset pos,
      {Size target,
      Offset rotationCenter,
      double angle = 0,
      flipped: false,
      Paint paint}) {
    if (target == null) {
      target = Size(image.width.toDouble(), image.height.toDouble());
    }
    assert(target.width > 0);
    assert(target.height > 0);
    if (paint == null) {
      paint = Paint();
    }

    double widthRatio = target.width / image.width;
    double heightRatio = target.height / image.height;

    canvas.save();

    if (angle != 0) {
      assert(rotationCenter != null);
      canvas.translate(rotationCenter.dx, rotationCenter.dy);
      canvas.rotate(angle);
      canvas.translate(-rotationCenter.dx, -rotationCenter.dy);
    }

    if (flipped) {
      canvas.translate(pos.dx, pos.dy);
      canvas.scale(-1, 1);
      canvas.translate(-pos.dx - image.width, -pos.dy);
    }

    canvas.translate(pos.dx, pos.dy);
    canvas.scale(widthRatio, heightRatio);
    canvas.translate(-pos.dx, -pos.dy);

    canvas.drawImage(
        image, pos, paint);

    canvas.restore();
  }

  void freezeAnimation({int frameNumber}) {
    if(frameNumber == null)
      gifInfo.freezeGif();
    else
      gifInfo.freezeGif(frameNumber: frameNumber);
  }

  void unfreezeAnimation() {
    gifInfo.unfreezeGif();
  }

}

abstract class CustomDrawer {
  Size screenSize;
  Size _relativeSize;
  Size actualSize;

  CustomDrawer(this._relativeSize);

  @mustCallSuper

  /// Return true if the drawer is ready to be painted
  bool isReady(Size screenSize) {
    if (this._relativeSize != null) {
      this.actualSize =
          GameUtils.relativeToAbsoluteSize(_relativeSize, screenSize.height);
    }

    this.screenSize = screenSize;
    return true;
  }

  void paint(
      Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition);

  ///Modify position to ignore the camera
  Offset cancelCamera(Offset position, Offset cameraPosition) {
    return position + cameraPosition;
  }

  void changeRelativeSize(Size size) {}


  /// To know if the git info is available (during asset change) before processing it
  bool isGifInfoAvailable() {
    return true;
  }
}
