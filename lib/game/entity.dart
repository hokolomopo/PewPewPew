import 'dart:math';
import 'dart:ui';

abstract class Entity{
  Offset position;
  MutableRectangle hitbox;
  //TODO sprite

  Entity(this.position, this.hitbox);

  void setPosition(Offset position){
    this.position = position;
    _updateHitboxPosition();

  }

  void setXPosition(double X){
    this.position = new Offset(X, this.position.dy);
    _updateHitboxPosition();
  }

  void setYPosition(double Y){
    this.position = new Offset(this.position.dx, Y);
    _updateHitboxPosition();
  }

  void _updateHitboxPosition(){
    this.hitbox.left = this.position.dx;
    this.hitbox.top = this.position.dy;
  }
}

abstract class MovingEntity extends Entity{
  Offset velocity = new Offset(0, 0);
  Offset acceleration = new Offset(0, 0);
  double weight = 1;

  MovingEntity(Offset position, MutableRectangle<num> hitbox) : super(position, hitbox);


  MovingEntity.withSpeed(Offset position, MutableRectangle<num> hitbox, this.velocity, this.acceleration) : super(position, hitbox);

  void move(Offset d){
    this.position += d;
    _updateHitboxPosition();
  }

  void accelerate(){
    this.velocity += this.acceleration;
  }

  void updateVelocity(){
    this.velocity += acceleration;
  }

  bool isMoving(){
    if(this.velocity.dx == 0.0 && this.velocity.dy == 0.0)
      return false;
    return true;
  }

  void addAcceleration(Offset acc){
    this.acceleration += (acc * weight);
  }

  void stop(){
    this.velocity = new Offset(0.0, 0.0);
    this.acceleration = new Offset(0.0, 0.0);
  }

}