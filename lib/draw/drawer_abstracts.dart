import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:info2051_2018/draw/paint_constants.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'assets_manager.dart';


/// Class to draw image. We consider that a png is a gif with only one image
abstract class ImagedDrawer extends CustomDrawer {
  AssetId assetId;
  AssetsManager assetsManager;
  GifInfo gifInfo;

  // For team specific assets
  int team;

  ImagedDrawer(Size relativeSize, this.assetId, {this.team})
      : super(relativeSize);

  @override
  bool isReady(Size screenSize) {
    super.isReady(screenSize);

    // Check if the asset is loaded
    bool isAssetLoaded = assetsManager.isAssetLoaded(
        assetId, relativeSize, team: team);

    if (isAssetLoaded) {
      if (gifInfo == null) {
        gifInfo = assetsManager.getGifInfo(assetId, relativeSize, team: team);
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
    print("Set asset to " + newGifId.toString());
    assetId = newGifId;
    gifInfo = null;
  }

  void drawFlippedImage(Canvas canvas, ui.Image image, Rect imgDims, {Paint paint}) {
    if (paint == null)
      paint = Paint();

    canvas.save();
    canvas.scale(-1, 1);

    double x = - imgDims.left - imgDims.width;
    canvas.drawImage(image, Offset(x, imgDims.top), paint);

    canvas.restore();
  }

}

abstract class CustomDrawer {
  Size screenSize;
  Size relativeSize;
  Size actualSize;

  CustomDrawer(this.relativeSize);

  @mustCallSuper
  /// Return true if the drawer is ready to be painted
  bool isReady(Size screenSize) {
    if (this.relativeSize != null) {
      this.actualSize =
          GameUtils.relativeToAbsoluteSize(relativeSize, screenSize.height);
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
}