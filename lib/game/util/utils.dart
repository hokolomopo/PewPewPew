import 'dart:math';
import 'dart:ui';

class GameUtils{
  static Offset absoluteToRelativeOffset(Offset offset, double screenHeight){
    return offset * 100 / screenHeight;
  }

  static Offset relativeToAbsoluteOffset(Offset offset, double screenHeight) {
    return offset / 100 * screenHeight;
  }

  static double relativeToAbsoluteDist(double dist, double screenHeight) {
    return dist / 100 * screenHeight;
  }

  static Point toPoint(Offset o){
    return new Point(o.dx, o.dy);
  }

  static Offset getDimFromSize(Size s){
    return new Offset(s.width, s.height);
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

  /// Return the norm of the offset (sqrt(x^2 + y^2))
  static double getNormOfOffset(Offset o){
    return sqrt(o.dx * o.dx + o.dy * o.dy);
  }

  ///Return the center of the rectangle
  static Offset getRectangleCenter(Rectangle r){
    return Offset(r.left + r.width / 2, r.top + r.height / 2);
  }

}