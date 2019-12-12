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
    if (gifInfo == null) print(assetId.toString() + " " + team.toString());
    return gifInfo.fetchNextFrame();
  }

  set gif(AssetId newGifId) {
    assetId = newGifId;
    gifInfo = null;
  }

  drawFlippedImage(Canvas canvas, ui.Image image, Offset pos, {Paint paint}) {
    drawResizedImage(
        canvas,
        image,
        Offset(pos.dx + image.width.toDouble(), pos.dy),
        Size(-image.width.toDouble(), image.height.toDouble()),
        paint: paint);
  }

  drawResizedImage(Canvas canvas, ui.Image image, Offset pos, Size target,
      {Paint paint}) {
    if (paint == null) paint = Paint();

    double widthRatio = target.width / image.width;
    double heightRatio = target.height / image.height;

    canvas.save();
    canvas.scale(widthRatio, heightRatio);

    canvas.drawImage(
        image, Offset(pos.dx / widthRatio, pos.dy / heightRatio), paint);

    canvas.restore();
  }

  ///Draw a image after a rotation, at a given position and you may give
  /// it an offset to add the the position of the rotated image
  void drawRotatedImage(ui.Image image, Canvas canvas, Offset rotationCenter,
      Offset position, double angle,
      {Paint paint, Offset offset = const Offset(0, 0), flipped: false}) {
    if (paint == null) paint = Paint();

    if (angle == null) angle = 0;

    canvas.save();
    canvas.translate(rotationCenter.dx, rotationCenter.dy);

    canvas.rotate(angle);

    if (!flipped)
      canvas.drawImage(
          image,
          Offset(position.dx - rotationCenter.dx + offset.dx,
              position.dy - rotationCenter.dy + offset.dy),
          Paint());
    else
      drawFlippedImage(
          canvas,
          image,
          Offset(position.dx - rotationCenter.dx - offset.dx,
              position.dy - rotationCenter.dy + offset.dy));

    canvas.restore();
  }

  drawFlippedResizedImage(
      Canvas canvas, ui.Image image, Offset pos, Size target,
      {Paint paint}) {
    drawResizedImage(
        canvas,
        image,
        Offset(pos.dx + target.width.toDouble(), pos.dy),
        Size(-target.width, target.height));
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

  void freezeAnimation({int frameNumber}) {}

  void unfreezeAnimation() {}

  /// To know if the git info is available (during asset change) before processing it
  bool isGifInfoAvailable() {
    return true;
  }
}
