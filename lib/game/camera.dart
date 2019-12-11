import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/game/game_main.dart';
import 'package:info2051_2018/game/util/utils.dart';

class Camera{
  static const double CameraSpeed = 1;
  static const double dampeningFactor = 10;
  static const double inertiaFactor = 2;

  /// Position of the top left corner of the camera
  Offset position;

  ///Offset used to define the zoom of the camera. When used, it will mess up all
  /// the inputs positions , as we didn't implement a method to transform the zoomed coordinates
  /// into the game coordinates. This should thus only be used for cinematic (when
  /// no input is needed) and as a dev tool.
  Offset zoom;

  Offset inertia = Offset(0, 0);
  bool isTouching = true;

  Camera(this.position, {this.zoom : const Offset(1,1)});

  void update(double elapsedTime){
    if(!isTouching) {
      this.position += inertia * elapsedTime;

    }
    inertia *= 0.95;

  }

  void dragOf(Offset vector){
    position += vector * CameraSpeed;
    inertia += Offset(pow(vector.dx, inertiaFactor) * vector.dx.sign, pow(vector.dy, inertiaFactor) * vector.dy.sign);
  }

  void resetInertia(){
    this.inertia = Offset(0,0);
  }

  void stopX(){
    inertia = Offset(0, inertia.dy);
  }

  void stopY(){
    inertia = Offset(inertia.dx, 0);
  }

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