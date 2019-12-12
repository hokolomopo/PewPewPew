import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/ui_drawer.dart';
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

  LevelPainter(this.camera, this.levelSize, this.assetsManager, {this.showHitBoxes = false});

  addElement(CustomDrawer customDrawer, {index}) {
    int actualIndex = index ?? ((elements.lastKey() ?? 0) + 1);
    elements.update(actualIndex, (value) => customDrawer,
        ifAbsent: () => customDrawer);

    if(customDrawer is ImagedDrawer)
      customDrawer.assetsManager = assetsManager;
  }

  removeElement(CustomDrawer toRemove) {
    // The equality operator should compare pointers, this is done on purpose
    elements.removeWhere((key, drawer) => (drawer == toRemove));
  }


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
  LoadingScreenDrawer loadingScreenDrawer;

  _LevelPainterAux(this.levelPainter, this.camera, this.levelSize, this.assetsManager);

  @override
  void paint(ui.Canvas canvas, Size size) {

    //Load the assets if this is not already done
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
          if(loadingScreenDrawer == null)
            loadingScreenDrawer = LoadingScreenDrawer();

          loadingScreenDrawer.paint(canvas, size, false, null);

          everyDrawerReady = false;
        }
      }

      if (!everyDrawerReady) {
        return;
      }
    }

    // The game is starting, lose pointer to loading screen for garbage collector
    levelPainter.gameStarted = true;
    loadingScreenDrawer = null;

    //Apply camera transforms
    Offset absoluteCameraPosition = applyCamera(camera, canvas, size);

    for (CustomDrawer drawer in levelPainter.elements.values) {
      // Check if the drawer is ready
      if (drawer.isReady(size)) {
        drawer.paint(
            canvas, size, levelPainter.showHitBoxes, absoluteCameraPosition);
      }
      // If not ready, load its asset
      else {
        if(drawer is ImagedDrawer)
            assetsManager.loadAsset(drawer.assetId, drawer.relativeSize);
      }
    }
  }

  //Apply camera offset to the canvas and return its absolute position for the drawing
  Offset applyCamera(Camera camera, Canvas canvas, Size screenSize) {
  Offset absoluteCameraPosition =
      GameUtils.relativeToAbsoluteOffset(camera.position, screenSize.height);
  Offset absoluteLevelSize = GameUtils.relativeToAbsoluteOffset(
      GameUtils.getDimFromSize(levelSize), screenSize.height);

  //Fix camera position to stay inside level limitss
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

  if(fixedX != absoluteCameraPosition.dx)
    camera.stopX();
  if(fixedY != absoluteCameraPosition.dy)
    camera.stopY();

  if(fixedX != absoluteCameraPosition.dx || fixedY != absoluteCameraPosition.dy) {
    absoluteCameraPosition = Offset(fixedX, fixedY);

    camera.position = GameUtils.absoluteToRelativeOffset(
        absoluteCameraPosition, screenSize.height);
  }

  // Apply camera transformation to the canvas
  canvas.translate(-absoluteCameraPosition.dx, -absoluteCameraPosition.dy);
  canvas.scale(camera.zoom.dx, camera.zoom.dy);

  return absoluteCameraPosition;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
