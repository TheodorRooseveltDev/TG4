import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/player_stats.dart';
import '../models/scene.dart';
import '../services/game_data_service.dart';
import '../services/game_save_service.dart';
import '../services/audio_service.dart';

// Game State Provider
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState.initial());

  void updateScene(String sceneId) {
    final updatedVisited = [...state.visitedScenes, sceneId];
    state = state.copyWith(
      currentSceneId: sceneId,
      visitedScenes: updatedVisited,
      lastPlayed: DateTime.now(),
    );
    
    // Auto-save on scene change
    GameSaveService.instance.saveGame(state, isAutoSave: true);
  }

  void updatePlayerStats(PlayerStats newStats) {
    state = state.copyWith(
      playerStats: newStats,
      lastPlayed: DateTime.now(),
    );
  }

  void updatePlayerName(String name) {
    final updatedStats = state.playerStats.copyWith(name: name);
    state = state.copyWith(
      playerStats: updatedStats,
      lastPlayed: DateTime.now(),
    );
    // Auto-save when name changes
    GameSaveService.instance.saveGame(state, isAutoSave: true);
  }

  void applyChoice(Map<String, dynamic> choiceEffects) {
    var stats = state.playerStats;

    // Apply stat changes
    if (choiceEffects['respect'] != null) {
      stats = stats.copyWith(respect: stats.respect + (choiceEffects['respect'] as int));
    }
    if (choiceEffects['truth'] != null) {
      stats = stats.copyWith(truthLevel: stats.truthLevel + (choiceEffects['truth'] as int));
    }
    if (choiceEffects['sanity'] != null) {
      stats = stats.copyWith(sanity: stats.sanity + (choiceEffects['sanity'] as int));
    }
    if (choiceEffects['money'] != null) {
      stats = stats.copyWith(money: stats.money + (choiceEffects['money'] as int));
    }
    if (choiceEffects['scarlettRomance'] != null) {
      stats = stats.copyWith(scarlettRomance: stats.scarlettRomance + (choiceEffects['scarlettRomance'] as int));
    }

    // Apply special flags
    if (choiceEffects['specialFlag'] != null) {
      final flags = Map<String, bool>.from(stats.specialFlags);
      flags[choiceEffects['specialFlag'] as String] = true;
      stats = stats.copyWith(specialFlags: flags);
    }

    // Set player name
    if (choiceEffects['setName'] == true && choiceEffects['name'] != null) {
      stats = stats.copyWith(name: choiceEffects['name'] as String);
    }

    updatePlayerStats(stats);
    
    // Auto-save after applying choice effects
    GameSaveService.instance.saveGame(state, isAutoSave: true);
  }

  void unlockCasino(String casinoId) {
    final updatedUnlockedCasinos = List<String>.from(state.unlockedCasinos);
    if (!updatedUnlockedCasinos.contains(casinoId)) {
      updatedUnlockedCasinos.add(casinoId);
      state = state.copyWith(
        unlockedCasinos: updatedUnlockedCasinos,
        lastPlayed: DateTime.now(),
      );
      // Auto-save when unlocking casino
      GameSaveService.instance.saveGame(state, isAutoSave: true);
    }
  }

  void completeCasino(String casinoId) {
    final updatedCompletedCasinos = List<String>.from(state.completedCasinos);
    if (!updatedCompletedCasinos.contains(casinoId)) {
      updatedCompletedCasinos.add(casinoId);
      state = state.copyWith(
        completedCasinos: updatedCompletedCasinos,
        lastPlayed: DateTime.now(),
      );
      // Auto-save when completing casino
      GameSaveService.instance.saveGame(state, isAutoSave: true);
    }
  }

  void loadGame(GameState loadedState) {
    state = loadedState;
  }

  Future<void> saveGame() async {
    await GameSaveService.instance.saveGame(state);
  }

  void resetGame() {
    state = GameState.initial();
  }
}

// Current Scene Provider
final currentSceneProvider = Provider<Scene?>((ref) {
  final gameState = ref.watch(gameStateProvider);
  final sceneId = gameState.currentSceneId;
  return GameDataService.instance.getScene(sceneId);
});

// Audio Service Provider
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService.instance;
});

// Game Data Service Provider
final gameDataServiceProvider = Provider<GameDataService>((ref) {
  return GameDataService.instance;
});
