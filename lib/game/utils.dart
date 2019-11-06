import 'dart:math';
import 'dart:ui';

class GameUtils{
  static Offset absoluteToRelativeOffset(Offset offset, double screenHeight){
    return offset * 100 / screenHeight;
  }

  static double relativeToAbsoluteDist(double dist, double screenHeight) {
    return dist / 100 * screenHeight;
  }

  static Point toPoint(Offset o){
    return new Point(o.dx, o.dy);
  }

  static bool rectContains(Rectangle rectangle, Offset offset){
    return rectangle.containsPoint(toPoint(offset));
  }

  static bool rectLeftOf(Rectangle rectangle, Offset offset){
    return rectangle.left + rectangle.width > offset.dx;
  }

  static bool rectRightOf(Rectangle rectangle, Offset offset){
    return rectangle.left < offset.dx;
  }

  static Rectangle extendRect(Rectangle rectangle, int extension){
    Rectangle extended =  new Rectangle(rectangle.left - extension, rectangle.top - extension,
        rectangle.width + 2*extension, rectangle.height + 2*extension);
    return extended;
  }

}