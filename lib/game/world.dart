import 'dart:core';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/entity.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/weaponry.dart';

import 'level.dart';

class World{
  final double gravityForce;

  static final double epsilon = 0.00000000001;
  
  List<Character> players = List();
  List<Projectile> projectiles = List();
  Set<TerrainBlock> terrain = Set();

  Offset gravity;

  void Function(List<CharacterDamagePair>) damageDealtCallback;

  World({this.gravityForce=0.02}){
    gravity = Offset(0, gravityForce);
  }

  void updateWorld(double timeElapsed){
    for(Projectile p in projectiles){
      if(p is ExplosiveProjectile && p.checkTTL())
        manageExplosion(p);

      p.addAcceleration(gravity);
      p.accelerate();
      moveEntity(p, timeElapsed);
    }

    for(Character c in players){
      c.updateAnimation();

      c.addAcceleration(gravity);
      c.accelerate();
      moveEntity(c, timeElapsed);
    }
  }


  void moveEntity(MovingEntity entity, double timeElapsed){

    //Move in X axis
    Offset vector = Offset(entity.velocity.dx, 0);
    entity.move(vector * timeElapsed);

    for(TerrainBlock t in terrain){
      if(entity.hitbox.intersects(t.hitbox)){
        if(entity is Projectile)
          manageProjectileCollision(entity, t);

        backTrackX(entity, t.hitbox, vector.dx);
        entity.stopX();
      }
    }

    //Move on Y axis
    vector = Offset(0, entity.velocity.dy);
    entity.move(vector * timeElapsed);

    for(TerrainBlock t in terrain){
      if(entity.hitbox.intersects(t.hitbox)){

        if(entity is Projectile)
          manageProjectileCollision(entity, t);

        backTrackY(entity, t.hitbox, vector.dy);
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

    if(entity is Projectile)
      for (Character c in players)
          if(c.hitbox.intersects(entity.hitbox))
            manageProjectileCollision(entity, c);

  }

  void manageProjectileCollision(Projectile projectile, Entity collided){

    // Projectiles that explode on hit
    if(projectile is ExplosiveProjectile && projectile.explodeOnImpact)
      manageExplosion(projectile);

    if (collided is TerrainBlock) {
      projectile.isDead = true;
      return;
    }
    else if (collided is Character) {
      // Update stats
      double damageDealt = min(projectile.damage.toDouble(), collided.hp);
      collided.removeHp(damageDealt);

      double velocity = projectile.knockBackStrength.toDouble();
      velocity *= projectile.velocity.dx.sign;
      collided.addVelocity(Offset(velocity, -velocity.abs()));

      List<CharacterDamagePair> l = List();
      l.add(CharacterDamagePair(collided, damageDealt));
      damageDealtCallback(l);

      projectile.isDead = true;
    }
  }

  void manageExplosion(ExplosiveProjectile projectile) {
    List<CharacterDamagePair> damageDealtList = List();

    for (Character char in this.players) {
      // apply a circular HitBox
      double dist = (projectile.getPosition() - char.getPosition()).distance;

      // The character is in the explosion radius
      if (dist <= projectile.explosionRange) {

        // Apply damage reduce according to dist [33% - 100%]
        double effectiveDamage = projectile.damage.toDouble();
        effectiveDamage *= (1.0 + 2.0 * (projectile.explosionRange - dist) / projectile.explosionRange) / 3.0;


        // Apply a vector field for knockback to know the direction
        Offset projection = char.getPosition() - projectile.getPosition();

        // Normalize offset
        projection = Offset(projection.dx.sign, 1);

        // The closer to the center of detonation the stronger the knockback
        // Factor from 0% to 100%
        projection *= (projectile.explosionRange - dist) / projectile.explosionRange;

        // Applied factor for knockback strenght
        projection *= projectile.knockBackStrength.toDouble();

        char.addVelocity(Offset(projection.dx, -projection.dx.abs()));

        // Update stats
        double damageDealt = min(effectiveDamage, char.hp);
        char.removeHp(damageDealt);
        damageDealtList.add(CharacterDamagePair(char, damageDealt));
      }
    }

    projectile.isDead = true;
    this.damageDealtCallback(damageDealtList);
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

  void registerDamageDealtCallback(void Function(List<CharacterDamagePair>) callback){
    this.damageDealtCallback = callback;
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
      if(block.hitbox.left > o.dx || block.hitbox.left + block.hitbox.width < o.dx)
        continue;

      else if(block.hitbox.containsPoint(GameUtils.toPoint(o)))
        return block;

      else if(block.hitbox.top < o.dy)
        continue;

      else{
        double dist = (block.hitbox.top - o.dy).abs();
        if(minDist == null || dist < minDist)
          minBlock = block;
          minDist = dist;
      }

    }

    return minBlock;
  }
}