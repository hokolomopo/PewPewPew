import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:info2051_2018/draw/character_drawer.dart';
import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/drawer_abstracts.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/sound_player.dart';

class Character extends MovingEntity {
  static const List<Color> teamColors = [Colors.red, Colors.blue, Colors.green, Colors.orange];

  static const int LEFT = 0;
  static const int RIGHT = 1;

  static const double base_hp = 100;
  static const double baseStamina = 100;
  static const double max_jump_speed = 50;
  static const double walk_speed = 20;

  static const Size spriteSize = Size(10, 10);
  static const Offset characterSpritePositionOffset = Offset(-2, 0);

  static const Offset hitboxSize = Offset(6,10);

  static const String hurtSoundName = "hurtSound.mp3";

  double hp = base_hp;
  int team;
  Arsenal currentArsenal;

  double stamina = baseStamina;

  bool _isAirborne = false;
  bool isDying = false;
  bool isDead = false;
  bool isLanding = false;
  bool isWalking = false;
  bool isIdle = true;

  int directionFaced = RIGHT;

  Character(Offset position, this.team) : super(position, MutableRectangle(position.dx, position.dy, hitboxSize.dx, hitboxSize.dy)){
    this.spritePositionOffset = characterSpritePositionOffset;
    this.drawer = CharacterDrawer(AssetId.char_idle, this, team: this.team);
    // TODO Initiate "correctly" arsenal
    this.currentArsenal = Arsenal([Fist(this.team), Colt(this.team)]);
  }

  void jump(Offset direction){
    //Do nothing if character is in the air
    if(_isAirborne)
      return;
    _isAirborne = true;

    //Make sure the jump is not totally horizontal for ease of collision detection
    if(direction.dy == 0)
      direction += Offset(0, 0.1);

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
    isDying = true;
    _isAirborne = false;
    isIdle = false;
    this.stop();
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

    this.isWalking = true;
    this.isIdle = false;
  }

  @override
  void stopX(){
    super.stopX();

    if(!isDying)
      this.isIdle = true;
    this.isWalking = false;
  }

  /// Override mode to update stamina when the character is moving and change its orientation
  @override
  void move(Offset o){
    super.move(o);

    // Reduce stamina
    this.stamina -= o.dx.abs();
    stamina = max(stamina, 0);

    // Update which side the character is facing
    if(o.dx > 0)
      this.directionFaced = RIGHT;
    else if(o.dx < 0)
      this.directionFaced = LEFT;

    this.isIdle = false;
  }

  /// Reset the character's stamina
  void refillStamina(){
    this.stamina = baseStamina;
  }

  Color getTeamColor(){
    return teamColors[team];
  }

  // Pass a sound Player ref to play hurt sound
  void removeHp(double damage, SoundPlayer soundPlayer){
    this.hp -= damage;

    if (this.hp < 0)
      this.hp = 0;

    if(this.hp == 0)
      this.kill();

    if(soundPlayer != null)
      soundPlayer.playLocalAudio(hurtSoundName, 1.0);
  }

  void updateAnimation(){
    ImagedDrawer drawer = this.drawer;

    //TODO fix animation when falling
    // Check if we need to change the animation
    if(this.isWalking && drawer.assetId != AssetId.char_running)
      drawer.gif = AssetId.char_running;
    else if(isAirborne() && drawer.assetId != AssetId.char_jumping)
      drawer.gif = AssetId.char_jumping;
    else if(isDying && drawer.assetId != AssetId.char_death)
      drawer.gif = AssetId.char_death;
    else if(isIdle && drawer.assetId != AssetId.char_idle)
      drawer.gif = AssetId.char_idle;

    // We don't need to change the animation
    else if(drawer.gifInfo != null){
      if(isDying && drawer.gifInfo.curFrameIndex == drawer.gifInfo.gif.length - 1){
        drawer.gifInfo.freezeGif();
        isDead = true;
      }
    }


  }
}