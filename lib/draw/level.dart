import 'dart:collection';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

abstract class CustomDrawer {
  bool isReady(Size screenSize) => true;
  TestListenable repaint;

  void paint(Canvas canvas, Size size);
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
      painter: _LevelPainterAux(elements, repaint),
    );
  }
}

class _LevelPainterAux extends CustomPainter {
  SplayTreeMap<int, CustomDrawer> toBePainted;

  _LevelPainterAux(this.toBePainted, Listenable repaint) :
    super(repaint: repaint);

  @override
  void paint(ui.Canvas canvas, Size size) {
    bool everyDrawerReady = true;
    for (CustomDrawer drawer in toBePainted.values) {
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

    for (CustomDrawer drawer in toBePainted.values) {
      drawer.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
