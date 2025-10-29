import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/scene.dart';

class GameDataService {
  static GameDataService? _instance;
  static GameDataService get instance {
    _instance ??= GameDataService._();
    return _instance!;
  }

  GameDataService._();

  Map<String, dynamic>? _gameData;

  Future<Map<String, dynamic>> loadGameData() async {
    final String jsonString = await rootBundle.loadString('assets/game_data.json');
    _gameData = json.decode(jsonString);
    return _gameData!;
  }

  Scene? getScene(String sceneId) {
    if (_gameData == null) return null;

    // Check prologue
    final prologue = _gameData!['prologue'] as Map<String, dynamic>;
    for (final entry in prologue.entries) {
      final sceneData = entry.value as Map<String, dynamic>;
      if (sceneData['id'] == sceneId) {
        return Scene.fromJson(sceneData);
      }
    }

    // Check casinos (future implementation)
    // Add similar logic for casino scenes

    return null;
  }

  List<Scene> getPrologueScenes() {
    if (_gameData == null) return [];

    final prologue = _gameData!['prologue'] as Map<String, dynamic>;
    return prologue.entries
        .map((e) => Scene.fromJson(e.value as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic>? getGameInfo() {
    return _gameData?['game'];
  }

  Map<String, dynamic>? getPastVersion(int loop) {
    if (_gameData == null) return null;
    
    final pastVersions = _gameData!['prologue']['past_versions_appear']['past_versions'] as List;
    return pastVersions.firstWhere(
      (v) => v['loop'] == loop,
      orElse: () => null,
    );
  }
}
