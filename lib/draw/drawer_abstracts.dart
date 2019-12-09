import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'assets_manager.dart';

abstract class ImagedDrawer extends CustomDrawer {
  AssetId gifId;
  AssetsManager assetsManager;
  GifInfo gifInfo;

  ImagedDrawer(Size relativeSize, this.gifId) : super(relativeSize);

  @override
  bool isReady(Size screenSize) {
    super.isReady(screenSize);

    bool databaseContainsImg = assetsManager.loadedAssets.containsKey(gifId) &&
        assetsManager.loadedAssets[gifId].containsKey(relativeSize);

    if (databaseContainsImg) {
      if (gifInfo == null) {
        gifInfo = GifInfo(assetsManager.loadedAssets[gifId][relativeSize]);
      }
      return fetchNextFrame() != null;
    }
    return false;
  }

  ui.Image fetchNextFrame() {
    return gifInfo.fetchNextFrame();
  }

  set gif(AssetId newGifId) {
    gifId = newGifId;
    gifInfo = null;
  }

  @override
  Map<AssetId, Size> get imagePathsAndSizes {
    Map<AssetId, Size> ret = Map();
    ret.putIfAbsent(gifId, () => relativeSize);
    return ret;
  }
}

abstract class CustomDrawer {
  Size screenSize;
  Size relativeSize;
  Size actualSize;

  CustomDrawer(this.relativeSize);

  @mustCallSuper
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

  // To be overridden by ImagedDrawers, used here for compatibility
  set assetsManager(AssetsManager assetsManager) {}
  set gif(AssetId newGifId) {}
  Map<AssetId, Size> get imagePathsAndSizes => Map();
}