import 'package:flutter/material.dart';
import 'package:info2051_2018/game/draw/assets_manager.dart';

import 'drawer_abstracts.dart';

class BackgroundDrawer extends ImagedDrawer {
  AssetId backgroundId;

  BackgroundDrawer(size, this.backgroundId)
      : super(size, backgroundId);

  @override
  void paint(Canvas canvas, Size size, showHitBoxes, Offset cameraPosition) {

    canvas.drawImage(fetchNextFrame(), Offset.zero, Paint());
  }
}
