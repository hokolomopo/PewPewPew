import 'dart:collection';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:info2051_2018/game/camera.dart';
import 'package:info2051_2018/game/util/utils.dart';

abstract class CustomDrawer {
  bool isReady(Size screenSize) => true;
  TestListenable repaint;

  void paint(Canvas canvas, Size size, bool showHitBoxes, Offset cameraPosition);

  ///Modify position to ignore the camera
  Offset cancelCamera(Offset position, Offset cameraPosition){
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

  _LevelPainterAux(this.levelPainter, this.camera, this.levelSize) :
    super(repaint: levelPainter.repaint);

  @override
  void paint(ui.Canvas canvas, Size size) {
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

    //Apply camera transforms
    Offset absoluteCameraPosition = applyCamera(camera, canvas, size);

    for (CustomDrawer drawer in levelPainter.elements.values) {
      drawer.paint(canvas, size, levelPainter.showHitBoxes, absoluteCameraPosition);
    }
  }

  ///Apply camera offset to the canvas and return its absolute position for the drawing
  Offset applyCamera(Camera camera, Canvas canvas, Size screenSize){
    Offset absoluteCameraPosition = GameUtils.relativeToAbsoluteOffset(camera.position, screenSize.height);
    Offset absoluteLevelSize = GameUtils.relativeToAbsoluteOffset(GameUtils.getDimFromSize(levelSize), screenSize.height);

    //Fix camera position to stay inside level limits
    double fixedX = absoluteCameraPosition.dx;
    double fixedY = absoluteCameraPosition.dy;
    if(fixedX < 0)
      fixedX = 0;
    else if(fixedX + screenSize.width > absoluteLevelSize.dx)
      fixedX = absoluteLevelSize.dx - screenSize.width;

    if(fixedY < 0)
      fixedY = 0;
    else if(fixedY + screenSize.height > absoluteLevelSize.dy)
      fixedY = absoluteLevelSize.dy - screenSize.height;

    absoluteCameraPosition = Offset(fixedX, fixedY);

    canvas.translate(- absoluteCameraPosition.dx, - absoluteCameraPosition.dy);
    canvas.scale(camera.zoom.dx, camera.zoom.dy);

    camera.position = GameUtils.absoluteToRelativeOffset(absoluteCameraPosition, screenSize.height);

    return absoluteCameraPosition;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
