import 'package:json_annotation/json_annotation.dart';

part 'player_stats.g.dart';

@JsonSerializable()
class PlayerStats {
  String name;
  int money;
  int respect;
  int ageDisplayed;
  int ageTrue;
  List<String> tokensCollected;
  bool alive;
  int sanity;
  int truthLevel;
  int scarlettRomance;
  String motherStatus;
  String fatherStatus;
  bool killerRevealed;
  
  // Track special flags and unlocked content
  Map<String, bool> specialFlags;
  List<String> unlockedScenes;
  
  PlayerStats({
    this.name = '',
    this.money = 50,
    this.respect = 0,
    this.ageDisplayed = 25,
    this.ageTrue = 5,
    this.tokensCollected = const [],
    this.alive = true,
    this.sanity = 100,
    this.truthLevel = 0,
    this.scarlettRomance = 0,
    this.motherStatus = 'unknown',
    this.fatherStatus = 'unknown',
    this.killerRevealed = false,
    this.specialFlags = const {},
    this.unlockedScenes = const [],
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatsFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerStatsToJson(this);

  PlayerStats copyWith({
    String? name,
    int? money,
    int? respect,
    int? ageDisplayed,
    int? ageTrue,
    List<String>? tokensCollected,
    bool? alive,
    int? sanity,
    int? truthLevel,
    int? scarlettRomance,
    String? motherStatus,
    String? fatherStatus,
    bool? killerRevealed,
    Map<String, bool>? specialFlags,
    List<String>? unlockedScenes,
  }) {
    return PlayerStats(
      name: name ?? this.name,
      money: money ?? this.money,
      respect: respect ?? this.respect,
      ageDisplayed: ageDisplayed ?? this.ageDisplayed,
      ageTrue: ageTrue ?? this.ageTrue,
      tokensCollected: tokensCollected ?? this.tokensCollected,
      alive: alive ?? this.alive,
      sanity: sanity ?? this.sanity,
      truthLevel: truthLevel ?? this.truthLevel,
      scarlettRomance: scarlettRomance ?? this.scarlettRomance,
      motherStatus: motherStatus ?? this.motherStatus,
      fatherStatus: fatherStatus ?? this.fatherStatus,
      killerRevealed: killerRevealed ?? this.killerRevealed,
      specialFlags: specialFlags ?? this.specialFlags,
      unlockedScenes: unlockedScenes ?? this.unlockedScenes,
    );
  }
  
  String getRespectTitle() {
    if (respect < 21) return 'Nobody';
    if (respect < 41) return 'Somebody';
    if (respect < 61) return 'Player';
    if (respect < 81) return 'High Roller';
    return 'Legend';
  }
}
