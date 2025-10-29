import 'package:json_annotation/json_annotation.dart';
import 'player_stats.dart';

part 'choice.g.dart';

@JsonSerializable()
class Choice {
  final String text;
  final int? respect;
  final int? truth;
  final int? sanity;
  final int? money;
  final String? response;
  final String? type;
  final bool? setName;
  final String? name;
  final bool? mythicPath;
  final int? realityBreak;
  final int? perception;
  final String? specialFlag;
  final String? memoryUnlock;
  final String? effect;
  final String? consequence;
  final String? revelation;
  final String? requirement;
  final bool? massiveRevelation;
  final bool? autoWin;
  final Map<String, dynamic>? specialEvent;
  
  Choice({
    required this.text,
    this.respect,
    this.truth,
    this.sanity,
    this.money,
    this.response,
    this.type,
    this.setName,
    this.name,
    this.mythicPath,
    this.realityBreak,
    this.perception,
    this.specialFlag,
    this.memoryUnlock,
    this.effect,
    this.consequence,
    this.revelation,
    this.requirement,
    this.massiveRevelation,
    this.autoWin,
    this.specialEvent,
  });

  factory Choice.fromJson(Map<String, dynamic> json) =>
      _$ChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$ChoiceToJson(this);
  
  bool canSelect(PlayerStats stats) {
    if (requirement == null) return true;
    
    // Parse requirements like "truth >= 3" or "respect >= 30"
    if (requirement!.contains('truth >=')) {
      final value = int.parse(requirement!.split('>=')[1].trim());
      return stats.truthLevel >= value;
    }
    if (requirement!.contains('respect >=')) {
      final value = int.parse(requirement!.split('>=')[1].trim());
      return stats.respect >= value;
    }
    
    return true;
  }
}
