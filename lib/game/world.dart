import 'dart:core';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/terrain.dart';
import 'package:info2051_2018/game/weaponry.dart';

class World{
  static final double gravityForce = 0.0005;

  static final double epsilon = 0.1;
  
  List<Character> players = new List();
  List<Projectile> projectiles = new List();
  List<Terrain> terrains = new List();

  Offset gravity = new Offset(0, gravityForce);

  void updateWorld(){
    for(Character c in players){
      if(c.isMoving()){
        c.addAcceleration(gravity);
        c.accelerate();
        moveEntity(c);
      }
    }
  }

  void moveEntity(MovingEntity entity){

    //Move in X axis
    Offset vector = new Offset(entity.velocity.dx, 0);
    entity.move(vector);

    for(Terrain t in terrains){
      if(entity.hitbox.intersects(t.hitbox)){
        backTrackX(entity, t.hitbox, vector.dx);
        entity.stopX();
      }
    }

    //Move on Y axis
    vector = new Offset(0, entity.velocity.dy);
    entity.move(vector);

    for(Terrain t in terrains){
      if(entity.hitbox.intersects(t.hitbox)){
        backTrackY(entity, t.hitbox, vector.dy);
        entity.stopY();

        if(entity is Character)
          entity.land();

      }
    }
  }

  //Used when a collision occurs in the X axis.
  //Backtrack the entity "backtracked" until it doesn't collide the hitbox "collided"
  void backTrackX(MovingEntity backtracked, Rectangle collided, double velocity){
    if(velocity > 0)
      backtracked.setXPosition(collided.left - backtracked.hitbox.width - epsilon);
    else
      backtracked.setXPosition(collided.left + collided.width + epsilon);
  }

  //Used when a collision occurs in the Y axis.
  //Backtrack the entity "backtracked" until it doesn't collide the hitbox "collided"
  void backTrackY(MovingEntity backtracked, Rectangle collided, double velocity){
    if(velocity > 0)
      backtracked.setYPosition(collided.top - backtracked.hitbox.height - epsilon);
    else
      backtracked.setYPosition(collided.top + collided.height + epsilon);
  }


  void addPlayer(Character c){
    players.add(c);
  }

  void addProjectile(Projectile p){
    projectiles.add(p);
  }

  void addTerrain(Terrain t){
    terrains.add(t);
  }

}