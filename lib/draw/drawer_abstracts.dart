import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'assets_manager.dart';


/// Class to draw image. We consider that a png is a gif with only one image
abstract class ImagedDrawer extends CustomDrawer {
  AssetId assetId;
  AssetsManager assetsManager;
  GifInfo gifInfo;

  ImagedDrawer(Size relativeSize, this.assetId) : super(relativeSize);

  @override
  bool isReady(Size screenSize) {
    super.isReady(screenSize);

    // Check if the asset is loaded
    bool isAssetLoaded = assetsManager.isAssetLoaded(assetId, relativeSize);

    if (isAssetLoaded) {
      if (gifInfo == null) {
        gifInfo = assetsManager.getGifInfo(assetId, relativeSize);
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