// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerStats _$PlayerStatsFromJson(Map<String, dynamic> json) => PlayerStats(
  name: json['name'] as String? ?? '',
  money: (json['money'] as num?)?.toInt() ?? 50,
  respect: (json['respect'] as num?)?.toInt() ?? 0,
  ageDisplayed: (json['ageDisplayed'] as num?)?.toInt() ?? 25,
  ageTrue: (json['ageTrue'] as num?)?.toInt() ?? 5,
  tokensCollected:
      (json['tokensCollected'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  alive: json['alive'] as bool? ?? true,
  sanity: (json['sanity'] as num?)?.toInt() ?? 100,
  truthLevel: (json['truthLevel'] as num?)?.toInt() ?? 0,
  scarlettRomance: (json['scarlettRomance'] as num?)?.toInt() ?? 0,
  motherStatus: json['motherStatus'] as String? ?? 'unknown',
  fatherStatus: json['fatherStatus'] as String? ?? 'unknown',
  killerRevealed: json['killerRevealed'] as bool? ?? false,
  specialFlags:
      (json['specialFlags'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  unlockedScenes:
      (json['unlockedScenes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$PlayerStatsToJson(PlayerStats instance) =>
    <String, dynamic>{
      'name': instance.name,
      'money': instance.money,
      'respect': instance.respect,
      'ageDisplayed': instance.ageDisplayed,
      'ageTrue': instance.ageTrue,
      'tokensCollected': instance.tokensCollected,
      'alive': instance.alive,
      'sanity': instance.sanity,
      'truthLevel': instance.truthLevel,
      'scarlettRomance': instance.scarlettRomance,
      'motherStatus': instance.motherStatus,
      'fatherStatus': instance.fatherStatus,
      'killerRevealed': instance.killerRevealed,
      'specialFlags': instance.specialFlags,
      'unlockedScenes': instance.unlockedScenes,
    };
