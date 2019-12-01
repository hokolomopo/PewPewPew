import 'dart:math';
import 'dart:ui';

class SerializableOffset{
  Offset o;

  SerializableOffset(this.o);

  SerializableOffset.fromJson(Map<String, dynamic> json){
    o = Offset(json['dx'], json['dy']);
  }

  Map<String, dynamic> toJson() =>
      {
        'dx': o.dx,
        'dy': o.dy,
      };

  Offset toOffset(){
    return o;
  }
}

class SerializableRectangle{
  Rectangle r;

  SerializableRectangle(this.r);

  SerializableRectangle.fromJson(Map<String, dynamic> json){
    r = Rectangle(json['x'], json['y'], json['w'], json['h']);
  }

  Map<String, dynamic> toJson() =>
      {
        'x': r.left,
        'y': r.top,
        'h': r.height,
        'w': r.width,
      };

  Rectangle toRectangle(){
    return r;
  }
}