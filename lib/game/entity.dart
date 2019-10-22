import 'dart:math';
import 'dart:ui';

abstract class Entity{
  Offset position;
  Rectangle hitbox;
  //TODO sprite

  Entity(this.position, this.hitbox);


}

abstract class MovingEntity extends Entity{
  Offset velocity;
  Offset acceleration;

  MovingEntity(Offset position, Rectangle<num> hitbox) : super(position, hitbox);


  MovingEntity.withSpeed(Offset position, Rectangle<num> hitbox, this.velocity, this.acceleration) : super(position, hitbox);

  void move(){
    this.position += velocity;
  }

  void updateVelocity(){
    this.velocity += acceleration;
  }
}