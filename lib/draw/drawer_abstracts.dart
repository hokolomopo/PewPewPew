import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/paint_constants.dart';
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
    bool isAssetLoaded = assetsManager.isAssetLoaded(
        assetId, _relativeSize, team: team);

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
    if (gifInfo == null)
      print(assetId.toString() + " " + team.toString());
    return gifInfo.fetchNextFrame();
  }

  set gif(AssetId newGifId) {
    assetId = newGifId;
    gifInfo = null;
  }

  /// Flip an image and then draw it on the canvas
  void drawFlippedImage(Canvas canvas, ui.Image image, Rect imgDims, {Paint paint}) {
    if (paint == null)
      paint = Paint();

    canvas.save();
    canvas.scale(-1, 1);

    double x = - imgDims.left - imgDims.width;
    canvas.drawImage(image, Offset(x, imgDims.top), paint);

    canvas.restore();
  }


  ///Draw a image after a rotation, at a given position and you may give
  /// it an offset to add the the position of the rotated image
  void drawRotatedImage(ui.Image image, Canvas canvas, Offset rotationCenter, Offset position, double angle,
      {Paint paint, Offset offset=const Offset(0,0), flipped:false}) {

    if (paint == null)
      paint = Paint();

    if(angle == null)
      angle = 0;

    canvas.save();
    canvas.translate(rotationCenter.dx, rotationCenter.dy);

    canvas.rotate(angle);

    //canvas.drawCircle(Offset(0,0), 10, debugShowHitBoxesPaint);

    if(!flipped)
      canvas.drawImage(image, Offset(position.dx - rotationCenter.dx + offset.dx, position.dy - rotationCenter.dy + offset.dy), Paint());
    else
      drawFlippedImage(canvas, fetchNextFrame(), Rect.fromLTWH(position.dx - rotationCenter.dx - offset.dx,
          position.dy - rotationCenter.dy + offset.dy, actualSize.width, actualSize.height));

    canvas.restore();
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

  void changeRelativeSize(Size size){}
  void freezeAnimation({int frameNumber}){}
  void unfreezeAnimation(){}
  /// To know if the git info is available (during asset change) before processing it
  bool isGifInfoAvailable() {return true;}
}