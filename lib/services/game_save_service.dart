import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class GameSaveService {
  static const String _saveKey = 'casino_clash_save';
  static const String _autoSaveKey = 'casino_clash_autosave';

  static GameSaveService? _instance;
  static GameSaveService get instance {
    _instance ??= GameSaveService._();
    return _instance!;
  }

  GameSaveService._();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveGame(GameState gameState, {bool isAutoSave = false}) async {
    if (_prefs == null) await initialize();

    final key = isAutoSave ? _autoSaveKey : _saveKey;
    final jsonString = json.encode(gameState.toJson());
    await _prefs!.setString(key, jsonString);
  }

  Future<GameState?> loadGame({bool fromAutoSave = false}) async {
    if (_prefs == null) await initialize();

    final key = fromAutoSave ? _autoSaveKey : _saveKey;
    final jsonString = _prefs!.getString(key);

    if (jsonString == null) return null;

    try {
      final jsonData = json.decode(jsonString);
      return GameState.fromJson(jsonData);
    } catch (e) {
      print('Error loading game: $e');
      return null;
    }
  }

  Future<bool> hasSavedGame() async {
    if (_prefs == null) await initialize();
    return _prefs!.containsKey(_saveKey);
  }

  Future<bool> hasAutoSave() async {
    if (_prefs == null) await initialize();
    return _prefs!.containsKey(_autoSaveKey);
  }

  Future<void> deleteSave({bool deleteAutoSave = false}) async {
    if (_prefs == null) await initialize();

    await _prefs!.remove(_saveKey);
    if (deleteAutoSave) {
      await _prefs!.remove(_autoSaveKey);
    }
  }

  Future<void> savePlayerChoice(String sceneId, int choiceIndex, Map<String, dynamic> choiceData) async {
    if (_prefs == null) await initialize();

    final key = 'choice_${sceneId}';
    final data = {
      'choiceIndex': choiceIndex,
      'choiceData': choiceData,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs!.setString(key, json.encode(data));
  }

  Future<Map<String, dynamic>?> getPlayerChoice(String sceneId) async {
    if (_prefs == null) await initialize();

    final key = 'choice_${sceneId}';
    final jsonString = _prefs!.getString(key);
    
    if (jsonString == null) return null;
    
    try {
      return json.decode(jsonString);
    } catch (e) {
      return null;
    }
  }
}
