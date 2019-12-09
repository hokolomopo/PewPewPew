import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:info2051_2018/game/util/utils.dart';

/// ui.FrameInfo is an interface
class MyFrameInfo {
  Duration duration;
  ui.Image image;
  DateTime addedTimestamp;

  MyFrameInfo(this.duration, this.image, [this.addedTimestamp]);
}

class GifInfo {
  List<MyFrameInfo> gif;
  DateTime lastFetch;
  int curFrameIndex = 0;

  // For projectile which get stuck
  bool lockAnimation = false;

  GifInfo(this.gif);

  ui.Image fetchNextFrame() {
    if (gif.length < 1) return null;

    if (lockAnimation)
      return gif[curFrameIndex].image;

    DateTime curTime = DateTime.now();
    Duration curDuration = gif[curFrameIndex].duration;
    if (lastFetch == null || curTime.difference(lastFetch) > curDuration) {
      lastFetch = curTime;
      if (curFrameIndex == gif.length - 1)
        curFrameIndex = 0;
      else
        curFrameIndex += 1;
    }

    return gif[curFrameIndex].image;
  }
}

abstract class ImagedDrawer extends CustomDrawer {
  String gifPath;
  Map<String, Map<Size, List<MyFrameInfo>>> imgAndGif;
  GifInfo gifInfo;

  ImagedDrawer(Size relativeSize, this.gifPath) : super(relativeSize);

  @override
  bool isReady(Size screenSize) {
    super.isReady(screenSize);

    bool databaseContainsImg = imgAndGif.containsKey(gifPath) &&
        imgAndGif[gifPath].containsKey(relativeSize);

    if (databaseContainsImg) {
      if (gifInfo == null) {
        gifInfo = GifInfo(imgAndGif[gifPath][relativeSize]);
      }
      return fetchNextFrame() != null;
    }
    return false;
  }

  ui.Image fetchNextFrame() {
    return gifInfo.fetchNextFrame();
  }

  set gif(String newGifPath) {
    gifPath = newGifPath;
    gifInfo = null;
  }

  @override
  Map<String, Size> get imagePathsAndSizes {
    Map<String, Size> ret = Map();
    ret.putIfAbsent(gifPath, () => relativeSize);
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
  set imgAndGif(Map<String, Map<Size, List<MyFrameInfo>>> imgAndGif) {}
  Map<String, Size> get imagePathsAndSizes => Map();
}