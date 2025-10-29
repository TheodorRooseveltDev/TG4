import 'package:json_annotation/json_annotation.dart';
import 'player_stats.dart';

part 'game_state.g.dart';

@JsonSerializable()
class GameState {
  final String currentSceneId;
  final PlayerStats playerStats;
  final List<String> visitedScenes;
  final Map<String, dynamic> sceneHistory; // Track choices made in each scene
  final DateTime lastPlayed;
  final int currentLoop;
  final List<String> unlockedCasinos; // Track which casinos are unlocked
  final List<String> completedCasinos; // Track which casinos have been completed
  final List<String> tokensCollected; // Track which tokens have been collected
  
  GameState({
    this.currentSceneId = 'intro_1',
    required this.playerStats,
    this.visitedScenes = const [],
    this.sceneHistory = const {},
    DateTime? lastPlayed,
    this.currentLoop = 18,
    this.unlockedCasinos = const ['casino_1'], // Casino 1 starts unlocked
    this.completedCasinos = const [], // No casinos completed initially
    this.tokensCollected = const [],
  }) : lastPlayed = lastPlayed ?? DateTime.now();

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  factory GameState.initial() {
    return GameState(
      currentSceneId: 'intro_1',
      playerStats: PlayerStats(),
      visitedScenes: [],
      sceneHistory: {},
      lastPlayed: DateTime.now(),
      currentLoop: 18,
      unlockedCasinos: ['casino_1'],
      completedCasinos: [],
      tokensCollected: [],
    );
  }

  GameState copyWith({
    String? currentSceneId,
    PlayerStats? playerStats,
    List<String>? visitedScenes,
    Map<String, dynamic>? sceneHistory,
    DateTime? lastPlayed,
    int? currentLoop,
    List<String>? unlockedCasinos,
    List<String>? completedCasinos,
    List<String>? tokensCollected,
  }) {
    return GameState(
      currentSceneId: currentSceneId ?? this.currentSceneId,
      playerStats: playerStats ?? this.playerStats,
      visitedScenes: visitedScenes ?? this.visitedScenes,
      sceneHistory: sceneHistory ?? this.sceneHistory,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      currentLoop: currentLoop ?? this.currentLoop,
      unlockedCasinos: unlockedCasinos ?? this.unlockedCasinos,
      completedCasinos: completedCasinos ?? this.completedCasinos,
      tokensCollected: tokensCollected ?? this.tokensCollected,
    );
  }
}
