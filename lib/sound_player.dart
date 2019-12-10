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
