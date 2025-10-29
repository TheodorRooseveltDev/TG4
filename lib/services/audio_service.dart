import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static AudioService? _instance;
  static AudioService get instance {
    _instance ??= AudioService._();
    return _instance!;
  }

  AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  String? _currentTrack;
  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _musicVolume = 0.7;
  double _sfxVolume = 1.0;

  Future<void> playMusic(String assetPath, {bool loop = true}) async {
    if (!_isMusicEnabled) return;
    
    if (_currentTrack == assetPath && _musicPlayer.state == PlayerState.playing) {
      return;
    }

    _currentTrack = assetPath;
    await _musicPlayer.stop();
    await _musicPlayer.setVolume(_musicVolume);
    await _musicPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
    await _musicPlayer.play(AssetSource(assetPath));
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _currentTrack = null;
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    await _musicPlayer.resume();
  }

  Future<void> playSfx(String sfxName) async {
    if (!_isSfxEnabled) return;
    
    await _sfxPlayer.stop();
    await _sfxPlayer.setVolume(_sfxVolume);
    
    // Map sfx names to actual sound effects
    String assetPath = 'music/'; // Default path
    
    switch (sfxName) {
      case 'choice':
        assetPath += 'choice_click.mp3';
        break;
      case 'dramatic':
        assetPath += 'dramatic_reveal.mp3';
        break;
      case 'thunder':
        assetPath += 'thunder_crash.mp3';
        break;
      default:
        return; // No sound for unknown effects
    }
    
    try {
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing SFX: $e');
    }
  }

  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    }
  }

  void setSfxEnabled(bool enabled) {
    _isSfxEnabled = enabled;
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
