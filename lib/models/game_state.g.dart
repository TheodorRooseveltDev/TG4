// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) => GameState(
  currentSceneId: json['currentSceneId'] as String? ?? 'intro_1',
  playerStats: PlayerStats.fromJson(
    json['playerStats'] as Map<String, dynamic>,
  ),
  visitedScenes:
      (json['visitedScenes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  sceneHistory: json['sceneHistory'] as Map<String, dynamic>? ?? const {},
  lastPlayed: json['lastPlayed'] == null
      ? null
      : DateTime.parse(json['lastPlayed'] as String),
  currentLoop: (json['currentLoop'] as num?)?.toInt() ?? 18,
  unlockedCasinos:
      (json['unlockedCasinos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['casino_1'],
  completedCasinos:
      (json['completedCasinos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  tokensCollected:
      (json['tokensCollected'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
  'currentSceneId': instance.currentSceneId,
  'playerStats': instance.playerStats,
  'visitedScenes': instance.visitedScenes,
  'sceneHistory': instance.sceneHistory,
  'lastPlayed': instance.lastPlayed.toIso8601String(),
  'currentLoop': instance.currentLoop,
  'unlockedCasinos': instance.unlockedCasinos,
  'completedCasinos': instance.completedCasinos,
  'tokensCollected': instance.tokensCollected,
};
