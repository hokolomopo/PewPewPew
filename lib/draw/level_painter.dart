import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/game/camera.dart';
import 'package:info2051_2018/game/util/utils.dart';

import 'drawer_abstracts.dart';
import 'assets_manager.dart';

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
  AssetsManager assetsManager;

  LevelPainter(this.camera, this.levelSize, {this.showHitBoxes = false}){
    assetsManager = AssetsManager(levelSize);
  }

  addElement(CustomDrawer customDrawer, {index}) {
    int actualIndex = index ?? ((elements.lastKey() ?? 0) + 1);
    elements.update(actualIndex, (value) => customDrawer,
        ifAbsent: () => customDrawer);

    //TODO if customDrawer is type ImageDrawer, et virer le champ imgAndGif du customDrawer
    customDrawer.assetsManager = assetsManager;
  }

  removeElement(CustomDrawer toRemove) {
    // The equality operator should compare pointers, this is done on purpose
    elements.removeWhere((key, drawer) => (drawer == toRemove));
  }


//  loadGame() async {
//    for (CustomDrawer drawer in elements.values) {
//      for (MapEntry<String, Size> entry in drawer.imagePathsAndSizes.entries) {
//        await addGif(entry.key, entry.value);
//      }
//    }
//  }

  /// Getter for the previously built level.
  ///
  /// Use this method to get the widget (painter) representing the level, it
  /// will then automatically paints the elements that have been created in its
  /// children.
  Widget get level {
    return CustomPaint(
      size: Size.infinite,
      painter: _LevelPainterAux(this, this.camera, this.levelSize, assetsManager),
    );
  }
}

class _LevelPainterAux extends CustomPainter {
  LevelPainter levelPainter;
  Camera camera;
  Size levelSize;
  AssetsManager assetsManager;

  _LevelPainterAux(this.levelPainter, this.camera, this.levelSize, this.assetsManager);

  @override
  void paint(ui.Canvas canvas, Size size) {
    if (!levelPainter.gameStarted) {
      if (!levelPainter.loading) {
        // Set loading here to benefit from the fact that this function is
        // synchronous
        levelPainter.loading = true;
        assetsManager.preLoadAssets();
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
        for (MapEntry<AssetId, Size> entry
            in drawer.imagePathsAndSizes.entries) {
          assetsManager
              .loadAsset(entry.key, entry.value);
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
