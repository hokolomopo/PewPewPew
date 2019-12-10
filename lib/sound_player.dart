import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';


// TODO all sound assets should be compress in small mp3 to keep a reasonnable size for the cache

class MySoundPlayer {
  static SoundPlayer soundPlayer;

  static SoundPlayer getInstance() {
    if (soundPlayer == null)
      soundPlayer = SoundPlayer();
    return soundPlayer;
  }
}

class SoundPlayer {
  AudioPlayer musicPlayer; // Use for loop music (one at a time)
  AudioCache musicCache; // Use for loop music
  AudioCache audioCache; // Use for sound effect, multiple play possible

  // final list for to pre load time sensitive files
  final List<String> noiseFileNames = ['hurtSound.mp3', 'explosion.mp3'];

  SoundPlayer() {
    this.audioCache = AudioCache(prefix: "sounds/game/");
    this.audioCache.loadAll(noiseFileNames);

    this.musicPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    this.musicCache =
        AudioCache(prefix: "sounds/menu/", fixedPlayer: musicPlayer);
  }

  void playSoundEffect(String fileName, {double volume = 1.0}) {
    this.audioCache.play(fileName, volume: volume);
  }

  void playLoopMusic(String fileName, {double volume = 1.0}) {
    if (!musicCache.loadedFiles.containsKey(fileName)) {
      this.musicCache.clearCache();
      this.musicCache.load(fileName);
    }
    this.musicCache.loop(fileName, volume: volume);
  }

  void pauseLoopMusic() {
    this.musicPlayer.pause();
  }

  void resumeLoopMusic(){
    this.musicPlayer.resume();
  }

}

//
//class SoundPlayer {
//  AudioPlayer audioPlayer;
//  AudioCache audioCache;
//  bool lowLatencyMode; // if true, play music. Else play sound effect otherwise.
//
//  // Static list for the lowLatencyMode to pre load the files
//  final List<String> noiseFileNames = ['hurtSound.mp3', 'explosion.mp3'];
//
//  SoundPlayer([bool lowLatencyMode = false]) {
//
//    this.lowLatencyMode = lowLatencyMode;
//
//    if (lowLatencyMode){
//      // New AudioPlayer instantiation each call for // calls
//      this.audioCache = AudioCache(prefix: "sounds/game/");
//      this.audioCache.loadAll(noiseFileNames); // Future fct in constructor
//    }
//    else{
//      this.audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
//      this.audioPlayer.setReleaseMode(ReleaseMode.LOOP);
//      this.audioCache = AudioCache(prefix: "sounds/menu/", fixedPlayer: this.audioPlayer);
//    }
//  }
//
//  // Volume percentage => [0., 1.]
//  void playLocalAudio(String fileName, [double volume = 1.0]) async {
//
//    if(lowLatencyMode){
//      this.audioCache.play(fileName, volume: volume);
//    }
//    else{
//      await this.audioCache.load(fileName);
//      this.audioCache.play(fileName, volume: volume);
//    }
//  }
//
//  void pause() async {
//    await this.audioPlayer.pause();
//  }
//
//  void resume() async {
//    await this.audioPlayer.resume();
//  }
//
//  void stop() async {
//    await this.audioPlayer.stop();
//  }
//
//  void release() async {
//    await this.audioPlayer.release();
//  }
//}
