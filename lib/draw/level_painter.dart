import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/game/camera.dart';
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

  GifInfo(this.gif);

  ui.Image fetchNextFrame() {
    if (gif.length < 1) return null;

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

abstract class CustomDrawer {
  Size screenSize;
  Size relativeSize;
  Size actualSize;
  String gifPath;
  Map<String, Map<Size, GifInfo>> imgAndGif;

  CustomDrawer(this.relativeSize, this.gifPath);

  @mustCallSuper
  bool isReady(Size screenSize) {
    if (this.relativeSize != null) {
      this.actualSize =
          GameUtils.relativeToAbsoluteSize(relativeSize, screenSize.height);
    }

    this.screenSize = screenSize;
    return true;
  }

  ui.Image fetchNextFrame() {
    return imgAndGif[gifPath][relativeSize].fetchNextFrame();
  }

  Map<String, Size> get imagePathsAndSizes {
    Map<String, Size> ret = Map();
    if (gifPath != null) ret.putIfAbsent(gifPath, () => relativeSize);
    return ret;
  }

  void paint(
      Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition);

  ///Modify position to ignore the camera
  Offset cancelCamera(Offset position, Offset cameraPosition) {
    return position + cameraPosition;
  }
}

class LevelPainter {
  // The keys of the SplayTreeMap define an order. That means that we first
  // paint the elements with low keys, which thus appear in the background.
  SplayTreeMap<int, CustomDrawer> elements = SplayTreeMap();
  bool showHitBoxes = false;
  Camera camera;
  Size screenSize;
  Size levelSize;
  bool gameStarted = false;
  bool loading = false;
  Map<String, Map<Size, GifInfo>> imgAndGif = Map();

  LevelPainter(this.camera, this.levelSize, {this.showHitBoxes = false});

  addElement(CustomDrawer customDrawer, {index}) {
    elements.update(
        index ?? ((elements.lastKey() ?? 0) + 1), (value) => customDrawer,
        ifAbsent: () => customDrawer);
    customDrawer.imgAndGif = imgAndGif;
  }

  removeElement(customDrawer) {
    // The equality operator should compare pointers, this is done on purpose
    elements.removeWhere((key, value) => (value == customDrawer));
  }

  addGif(String path, Size relativeSize) async {
    if (imgAndGif.containsKey(path) &&
        imgAndGif[path].containsKey(relativeSize)) return;

    List<MyFrameInfo> curGif = List();
    int targetWidth =
        GameUtils.relativeToAbsoluteDist(relativeSize.width, screenSize.height)
            .toInt();
    int targetHeight =
        GameUtils.relativeToAbsoluteDist(relativeSize.height, screenSize.height)
            .toInt();

    Uint8List gifBytes = (await rootBundle.load(path)).buffer.asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(gifBytes);

    ui.FrameInfo info;
    ui.Image img;
    Uint8List byteData;
    for (int i = 0; i < codec.frameCount; i++) {
      info = await codec.getNextFrame();
      img = info.image;
      byteData = (await img.toByteData()).buffer.asUint8List();

      ui.decodeImageFromPixels(
          byteData, img.width, img.height, ui.PixelFormat.rgba8888,
          (ui.Image result) {
        curGif.add(MyFrameInfo(info.duration, result));
      }, targetWidth: targetWidth, targetHeight: targetHeight);
    }

    Map<Size, GifInfo> curSizes = imgAndGif.putIfAbsent(path, () => Map());
    curSizes.putIfAbsent(relativeSize, () => GifInfo(curGif));
  }

  loadGame() async {
    for (CustomDrawer drawer in elements.values) {
      for (MapEntry<String, Size> entry in drawer.imagePathsAndSizes.entries) {
        await addGif(entry.key, entry.value);
      }
    }
  }

  /// Getter for the previously built level.
  ///
  /// Use this method to get the widget (painter) representing the level, it
  /// will then automatically paints the elements that have been created in its
  /// children.
  Widget get level {
    return CustomPaint(
      size: Size.infinite,
      painter: _LevelPainterAux(this, this.camera, this.levelSize),
    );
  }
}

class _LevelPainterAux extends CustomPainter {
  LevelPainter levelPainter;
  Camera camera;
  Size levelSize;

  _LevelPainterAux(this.levelPainter, this.camera, this.levelSize);

  @override
  void paint(ui.Canvas canvas, Size size) {
    if (!levelPainter.gameStarted) {
      if (!levelPainter.loading) {
        // Set loading here to benefit from the fact that this function is
        // synchronous
        levelPainter.loading = true;
        levelPainter.loadGame();
      }

      bool everyDrawerReady = true;
      for (CustomDrawer drawer in levelPainter.elements.values) {
        if (!drawer.isReady(size) && everyDrawerReady) {
          // TODO real loading screen
          ui.ParagraphBuilder textBuilder = ui.ParagraphBuilder(
              ui.ParagraphStyle(textAlign: TextAlign.left, fontSize: 50.0))
            ..pushStyle(ui.TextStyle(color: Colors.white))
            ..addText('loading...');
          ui.Paragraph text = textBuilder.build()
            ..layout(ui.ParagraphConstraints(
                width: (size.width < 250) ? size.width : 250));

          canvas.drawParagraph(
              text,
              Offset((size.width - text.width) / 2,
                  (size.height - text.height) / 2));

          everyDrawerReady = false;
        }
      }

      if (!everyDrawerReady) {
        return;
      }
    }

    levelPainter.gameStarted = true;

    //Apply camera transforms
    Offset absoluteCameraPosition = applyCamera(camera, canvas, size);

    for (CustomDrawer drawer in levelPainter.elements.values) {
      if (drawer.isReady(size)) {
        drawer.paint(
            canvas, size, levelPainter.showHitBoxes, absoluteCameraPosition);
      } else {
        for (MapEntry<String, Size> entry in drawer.imagePathsAndSizes.entries) {
          levelPainter.addGif(entry.key, entry.value);
        }
      }
    }
  }

  ///Apply camera offset to the canvas and return its absolute position for the drawing
  Offset applyCamera(Camera camera, Canvas canvas, Size screenSize) {
    Offset absoluteCameraPosition =
        GameUtils.relativeToAbsoluteOffset(camera.position, screenSize.height);
    Offset absoluteLevelSize = GameUtils.relativeToAbsoluteOffset(
        GameUtils.getDimFromSize(levelSize), screenSize.height);

    //Fix camera position to stay inside level limits
    double fixedX = absoluteCameraPosition.dx;
    double fixedY = absoluteCameraPosition.dy;
    if (fixedX < 0)
      fixedX = 0;
    else if (fixedX + screenSize.width > absoluteLevelSize.dx)
      fixedX = absoluteLevelSize.dx - screenSize.width;

    if (fixedY < 0)
      fixedY = 0;
    else if (fixedY + screenSize.height > absoluteLevelSize.dy)
      fixedY = absoluteLevelSize.dy - screenSize.height;

    absoluteCameraPosition = Offset(fixedX, fixedY);

    canvas.translate(-absoluteCameraPosition.dx, -absoluteCameraPosition.dy);
    canvas.scale(camera.zoom.dx, camera.zoom.dy);

    camera.position = GameUtils.absoluteToRelativeOffset(
        absoluteCameraPosition, screenSize.height);

    return absoluteCameraPosition;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
