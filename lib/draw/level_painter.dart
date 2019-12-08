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

  MyFrameInfo(this.duration, this.image, this.addedTimestamp);
}

abstract class CustomDrawer {
  TestListenable repaint;
  List<MyFrameInfo> gif;
  Size screenSize;
  Size relativeSize;
  Size actualSize;
  String gifPath;
  DateTime lastFetch;
  int curFrameIndex;
  DateTime lastSizeUpdate;
  int frameCount;
  int updating = 0;

  CustomDrawer(this.relativeSize, this.gifPath, {screenSize}) {
    if (screenSize == null) return;

    updateScreenSize(screenSize);
  }

  bool isReady(Size screenSize) {
    if (this.screenSize != screenSize) {
      updateScreenSize(screenSize);
      return false;
    }
    if (updating != 0) {
      return false;
    }
    return true;
  }

  ui.Image fetchNextFrame() {
    if (gif.length > frameCount) {
      List<MyFrameInfo> mostRecent = List();
      for(MyFrameInfo info in gif) {
        if (info.addedTimestamp == lastSizeUpdate) {
          mostRecent.add(info);
        }
      }
      gif = mostRecent;
    }

    if (gif.length < 2) //[curFrameIndex] == 0
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

  updateScreenSize(Size screenSize) {
    updating += 1;
    lastSizeUpdate = DateTime.now();
    _updateScreenSize(screenSize, lastSizeUpdate.add(Duration(seconds: 0)));
  }

  _updateScreenSize(Size screenSize, DateTime callTimestamp) async {
    if (gifPath != null) {
      gif = List();
      curFrameIndex = 0;
      int targetWidth =
      GameUtils.relativeToAbsoluteDist(relativeSize.width, screenSize.height)
          .toInt();
      int targetHeight =
      GameUtils.relativeToAbsoluteDist(relativeSize.height, screenSize.height)
          .toInt();

      Uint8List gifBytes = (await rootBundle.load(gifPath)).buffer
          .asUint8List();
      ui.Codec codec = await ui.instantiateImageCodec(gifBytes);
      frameCount = codec.frameCount;

      ui.FrameInfo info;
      ui.Image img;
      Uint8List byteData;
      for (int i = 0; i < frameCount; i++) {
        info = await codec.getNextFrame();
        img = info.image;
        byteData = (await img.toByteData()).buffer.asUint8List();

        ui.decodeImageFromPixels(
            byteData, img.width, img.height, ui.PixelFormat.rgba8888,
                (ui.Image result) {
              this.gif.add(MyFrameInfo(info.duration, result, callTimestamp));
            }, targetWidth: targetWidth, targetHeight: targetHeight);
      }
    }

    if (this.relativeSize != null) {
      this.actualSize =
          GameUtils.relativeToAbsoluteSize(relativeSize, screenSize.height);
    }

    this.screenSize = screenSize;
    updating -= 1;
    //repaint.notifyListeners();
  }

  void paint(
      Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition);

  ///Modify position to ignore the camera
  Offset cancelCamera(Offset position, Offset cameraPosition) {
    return position + cameraPosition;
  }
}

class TestListenable extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

class LevelPainter {
  SplayTreeMap<int, CustomDrawer> elements = SplayTreeMap();
  TestListenable repaint = TestListenable();
  bool showHitBoxes = false;
  Camera camera;
  Size levelSize;
  bool gameStarted = false;

  LevelPainter(this.camera, this.levelSize, {this.showHitBoxes = false});

  addElement(CustomDrawer customDrawer, {index}) {
    // Did not find a simple addElement method in the SplayTreeMap, but this
    // does the job and even handle duplicated keys.
    elements.update(
        index ?? ((elements.lastKey() ?? 0) + 1), (value) => customDrawer,
        ifAbsent: () => customDrawer);
    customDrawer.repaint = repaint;
  }

  removeElementByIndex(index) {
    elements.remove(index);
  }

  removeElement(customDrawer) {
    // The equality operator should compare pointers, this is done on purpose
    elements.removeWhere((key, value) => (value == customDrawer));
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

  _LevelPainterAux(this.levelPainter, this.camera, this.levelSize)
      : super(repaint: levelPainter.repaint);

  @override
  void paint(ui.Canvas canvas, Size size) {
    if (!levelPainter.gameStarted) {
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
