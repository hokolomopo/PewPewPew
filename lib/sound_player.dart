import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

import 'menu/home.dart';

class SoundPlayer {
  static SoundPlayer soundPlayer;

  static SoundPlayer getInstance() {
    if (soundPlayer == null)
      soundPlayer = SoundPlayer._();
    return soundPlayer;
  }

  static const menuMusicName = "sample.mp3";
  static const gameMusicName = "sample2.mp3";

  static double musicVolume = Home.musicVolume; // [0.0, 1.0]
  static double currentMusicVolume; //[0.0, 1.0]
  static double sfxVolume = Home.sfxVolume; // [0.0, 1.0]

  AudioPlayer musicPlayer; // Use for loop music (one at a time)
  AudioCache musicCache; // Use for loop music
  AudioCache audioCache; // Use for sound effect, multiple play possible

  // final list for to pre load time sensitive files
  final List<String> noiseFileNames = ['hurtSound.mp3', 'explosion.mp3', 'spell.mp3'];

  SoundPlayer._() {
    this.audioCache = AudioCache(prefix: "sounds/noise/");
    this.audioCache.loadAll(noiseFileNames);

    this.musicPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    this.musicCache =
        AudioCache(prefix: "sounds/music/", fixedPlayer: musicPlayer);
  }

  void playSoundEffect(String fileName, {double volume = 1.0}) {
    this.audioCache.play(fileName, volume: volume * sfxVolume);
  }

  void playLoopMusic(String fileName, {double volume = 1.0}) {
    if (!musicCache.loadedFiles.containsKey(fileName)) {
      this.musicCache.clearCache();
      this.musicCache.load(fileName);
    }
    currentMusicVolume = volume;
    this.musicCache.loop(fileName, volume: volume * musicVolume);
  }

  void pauseLoopMusic() {
    this.musicPlayer.pause();
  }

  void resumeLoopMusic(){
    this.musicPlayer.resume();
  }

  release() {
    this.musicPlayer.release();
  }

  set musicVolumeScale(double newVolume){
    if(newVolume < 0.0 || newVolume > 1.0)
      musicVolume = 1.0;
    else
      musicVolume = newVolume;

    if(musicPlayer != null && currentMusicVolume != null)
      musicPlayer.setVolume(musicVolume * currentMusicVolume);
  }

  set sfxVolumeScale(double newVolume){
    if(newVolume < 0.0 || newVolume > 1.0)
      sfxVolume = 1.0;
    else
      sfxVolume = newVolume;
  }

}
