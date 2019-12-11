import 'dart:core';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weaponry.dart';
import 'package:info2051_2018/quickplay_widgets.dart';

import 'level.dart';

class World{
  final double gravityForce;

  static final double epsilon = 0.00000000001;
  
  List<Character> players = List();
  List<Projectile> projectiles = List();
  Set<TerrainBlock> terrain = Set();

  Offset gravity;

  World({this.gravityForce=0.02}){
    gravity = Offset(0, gravityForce);
  }

  void updateWorld(double timeElapsed){
    for(Character c in players){
      c.updateAnimation();

      if(c.isMoving()){
        c.addAcceleration(gravity);
        c.accelerate();
        moveEntity(c, timeElapsed);
      }
    }

    for(Projectile p in projectiles){
      // Linear trajectory projectile aren't affect by gravity
      if(!(p is Linear) ){
        p.addAcceleration(gravity);
        p.accelerate();
      }
      moveEntity(p, timeElapsed);
    }
  }

  // To be sure no problem at launch
  // Exception for actual caractere
  bool checkCollidableProj(Character actualCharacter) {
    for (Projectile p in projectiles) {
      if (!(p is CollidableProjectile))
        return false;

      // First check terrains
      for (TerrainBlock t in terrain)
        if (t.hitBox.intersects(p.hitbox))
          return true;

      for (Character c in players)
        if(c != actualCharacter)
          if(c.hitbox.intersects(p.hitbox))
            return true;
    }

    return false;
  }
  void moveEntity(MovingEntity entity, double timeElapsed){

    //Move in X axis
    Offset vector = Offset(entity.velocity.dx, 0);
    entity.move(vector * timeElapsed);

    for(TerrainBlock t in terrain){
      if(entity.hitbox.intersects(t.hitBox)){
        backTrackX(entity, t.hitBox, vector.dx);
        entity.stopX();
      }
    }

    //Move on Y axis
    vector = Offset(0, entity.velocity.dy);
    entity.move(vector * timeElapsed);

    for(TerrainBlock t in terrain){
      if(entity.hitbox.intersects(t.hitBox)){
        backTrackY(entity, t.hitBox, vector.dy);
        entity.stopY();

        //If vector.dy == gravity, it means that there was only 1 frame of falling.
        //This will happens because the character is always slightly above the ground,
        //not on it. This is nto a real landing, it is due to the physics engine.
        if(vector.dy > gravity.dy && entity is Character)
          entity.land();

        // For Projectiles, simulate a friction force proportional to their
        // friction factor. The highest it is, the highest the friction will be.
        if(vector.dy > gravity.dy && entity is Projectile){
          entity.applyFriction();
        }
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


  void addCharacter(Character c){
    players.add(c);
  }

  void addProjectile(Projectile p){
    projectiles.add(p);
  }

  void addTerrain(TerrainBlock t){
    terrain.add(t);
  }

  void removeCharacter(Character c){
    players.remove(c);
  }

  void removeProjectile(Projectile p){
    projectiles.remove(p);
  }

  void removeTerrain(TerrainBlock t){
    terrain.remove(t);
  }

  /// Return the closest terrain that is under or that contains the given point
  TerrainBlock getClosestTerrainUnder(Offset o){
    TerrainBlock minBlock;
    double minDist;

    for(TerrainBlock block in terrain){
      if(block.hitBox.left > o.dx || block.hitBox.left + block.hitBox.width < o.dx)
        continue;

      else if(block.hitBox.containsPoint(GameUtils.toPoint(o)))
        return block;

      else if(block.hitBox.top < o.dy)
        continue;

      else{
        double dist = (block.hitBox.top - o.dy).abs();
        if(minDist == null || dist < minDist)
          minBlock = block;
          minDist = dist;
      }

    }

    return minBlock;
  }
}