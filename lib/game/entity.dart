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

  void addVelocity(Offset v){
    this.velocity += v;
  }

  void setXSpeed(double x){
    this.velocity = new Offset(x, this.velocity.dy);
  }

  void setYSpeed(double y){
    this.velocity = new Offset(this.velocity.dx, y);
  }

  void stopY(){
    this.setYSpeed(0);
    this.setYAcceleration(0);
  }

  void stopX(){
    this.setXSpeed(0);
    this.setXAcceleration(0);
  }

  void stop(){
    this.stopX();
    this.stopY();
  }

  bool isMoving(){
    if(this.velocity.dx == 0.0 && this.velocity.dy == 0.0)
      return false;
    return true;
  }

  void addAcceleration(Offset acc){
    this.acceleration += (acc * weight);
  }

  void setXAcceleration(double x){
    this.acceleration = new Offset(x, this.acceleration.dy);
  }

  void setYAcceleration(double y){
    this.acceleration = new Offset(this.acceleration.dx, y);
  }

}