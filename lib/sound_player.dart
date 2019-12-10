import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';


// TODO all sound assets should be compress in small mp3 to keep a reasonnable size for the cache

class SoundPlayer {
  AudioPlayer audioPlayer;
  AudioCache audioCache;
  bool lowLatencyMode; // if true, play music. Else play sound effect otherwise.
  int increment = 0;

  // Static list for the lowLatencyMode to pre load the files
  final List<String> noiseFileNames = ['hurtSound.mp3', 'explosion.mp3'];

  SoundPlayer([bool lowLatencyMode = false]) {

    this.lowLatencyMode = lowLatencyMode;

    if (lowLatencyMode){
      // New AudioPlayer instantiation each call for // calls
      this.audioCache = AudioCache(prefix: "sounds/game/");
      this.audioCache.loadAll(noiseFileNames); // Future fct in constructor
    }
    else{
      this.audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
      this.audioPlayer.setReleaseMode(ReleaseMode.LOOP);
      this.audioCache = AudioCache(prefix: "sounds/menu/", fixedPlayer: this.audioPlayer);
    }
  }

  // Volume percentage => [0., 1.]
  void playLocalAudio(String fileName, [double volume = 1.0]) async {

    if(lowLatencyMode){
      this.audioCache.play(fileName, volume: volume);
    }
    else{
      await this.audioCache.load(fileName);
      this.audioCache.play(fileName, volume: volume);
    }
  }

  void pause() async {
    await this.audioPlayer.pause();
  }

  void resume() async {
    await this.audioPlayer.resume();
  }

  void stop() async {
    await this.audioPlayer.stop();
  }

  void release() async {
    await this.audioPlayer.release();
  }
}
