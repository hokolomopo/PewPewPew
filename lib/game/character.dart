import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/Character.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weaponry.dart';

class Character extends MovingEntity {
  static const List<Color> teamColors = [Colors.red, Colors.blue, Colors.green, Colors.orange];

  static const int LEFT = 0;
  static const int RIGHT = 1;

  static const int base_hp = 100;
  static const double baseStamina = 10000;
  static const double max_jump_speed = 50;
  static const double walk_speed = 20;

  static final Offset hitboxSize = new Offset(10,10);

  //TODO truc propre pour les assets
  static final String asset = "assets/graphics/user_interface/animated-worm-image-0090.gif";

  int hp = base_hp;
  int team;
  Arsenal currentArsenal;

  double stamina = baseStamina;

  bool _isAirborne = false;

  bool isDead = false;

  Character(Offset position, this.team) : super(position, new MutableRectangle(position.dx, position.dy, hitboxSize.dx, hitboxSize.dy)){
    this.drawer = new CharacterDrawer(asset, this);
    // TODO Initiate "correctly" arsenal
    this.currentArsenal = new Arsenal([Fist(), Colt()]);

  }

  void jump(Offset direction){
    //Do nothing if character is in the air
    if(_isAirborne)
      return;
    _isAirborne = true;

    //Make sure the jump is not totally horizontal for ease of collision detection
    if(direction.dy == 0)
      direction += new Offset(0, 0.1);

    direction = getJumpSpeed(direction);
    //Limit the speed of the jump to max_jump_speed

    this.velocity += direction;
  }

  ///Function that limit the speed of a jump based on max_jump_speed
  static Offset getJumpSpeed(Offset direction){
    double jumpSpeed = GameUtils.getNormOfOffset(direction);
    if(jumpSpeed > max_jump_speed){
      direction /= (jumpSpeed / max_jump_speed);
    }
    return direction;
  }

  void land(){
    _isAirborne = false;
    this.stopX();
  }

  bool isAirborne(){
    return _isAirborne || velocity.dy != 0;
  }

  void kill(){
    //TODO maybe death animation
    isDead = true;
  }

  void beginWalking(int direction){
    //Do nothing if character is in the air
    if(isAirborne())
      return;

    //Get velocity corresponding to direction
    double newXSpeed;
    if(direction == LEFT)
      newXSpeed = -walk_speed;
    else if(direction == RIGHT)
      newXSpeed = walk_speed;

    //Set the velocity
    this.setXSpeed(newXSpeed);
  }

  /// Override mode to update stamina when the character is moving
  @override
  void move(Offset o){
    super.move(o);

    this.stamina -= o.dx.abs();
    stamina < 0 ? stamina = 0 : stamina = stamina;
  }

  /// Reset the character's stamina
  void refillStamina(){
    this.stamina = baseStamina;
  }

  Color getTeamColor(){
    return teamColors[team];
  }

  void removeHp(int damage){
    this.hp -= damage;

    // TODO Handle death
    if (this.hp < 0)
      this.hp = 0;
  }

}