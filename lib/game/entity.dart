import 'dart:math';
import 'dart:ui';

import 'package:info2051_2018/draw/drawer_abstracts.dart';

abstract class Entity{
  Offset _position;
  MutableRectangle hitbox;
  CustomDrawer drawer;
  Offset spritePositionOffset = Offset(0, 0);

  Entity.empty();

  Entity(this._position, this.hitbox);

  void setPosition(Offset position){
    this._position = position;
    _updateHitboxPosition();
  }

  void setXPosition(double X){
    this._position = new Offset(X, this._position.dy);
    _updateHitboxPosition();
  }

  void setYPosition(double Y){
    this._position = new Offset(this._position.dx, Y);
    _updateHitboxPosition();
  }

  void _updateHitboxPosition(){
    this.hitbox.left = this._position.dx;
    this.hitbox.top = this._position.dy;
  }

  Offset getPosition(){
    return Offset(hitbox.left, hitbox.top);
  }

  Offset getSpritePosition(){
    return getPosition() + spritePositionOffset;
  }
}

abstract class MovingEntity extends Entity{
  Offset velocity = new Offset(0, 0);
  Offset acceleration = new Offset(0, 0);
  double weight = 1;

  bool isDead = false;

  MovingEntity(Offset position, MutableRectangle<num> hitbox) : super(position, hitbox);


  MovingEntity.withSpeed(Offset position, MutableRectangle<num> hitbox, this.velocity, this.acceleration) : super(position, hitbox);

  void move(Offset d){
    this._position += d;
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