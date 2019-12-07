import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/util/utils.dart';

class Camera{
  /// Position of the top left corner of the camera
  Offset position;

  ///Offset used to define the zoom of the camera. When used, it will mess up all
  /// the inputs positions , as we didn't implement a method to transform the zoomed coordinates
  /// into the game coordinates. This should thus only be used for cinematic (when
  /// no input is needed) and as a dev tool.
  Offset zoom;

  Camera(this.position, {this.zoom : const Offset(1,1)});

  ///Center the camera on the given position
  void centerOn(Offset center){
    Offset screenSize = GameUtils.absoluteToRelativeOffset(Offset(GameMain.size.width, GameMain.size.height),
        GameMain.size.height);

    position = Offset(center.dx - screenSize.dx / 2, center.dy - screenSize.dy / 2);
  }

  bool isDisplayed(Rectangle rect){
    Offset screenSize = GameUtils.absoluteToRelativeOffset(Offset(GameMain.size.width, GameMain.size.height),
        GameMain.size.height);

    Rectangle screen = Rectangle(position.dx, position.dy, screenSize.dx, screenSize.dy);

    if(screen.containsRectangle(rect) || screen.intersects(rect))
      return true;

    return false;
  }
}