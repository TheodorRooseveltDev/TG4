// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Choice _$ChoiceFromJson(Map<String, dynamic> json) => Choice(
  text: json['text'] as String,
  respect: (json['respect'] as num?)?.toInt(),
  truth: (json['truth'] as num?)?.toInt(),
  sanity: (json['sanity'] as num?)?.toInt(),
  money: (json['money'] as num?)?.toInt(),
  response: json['response'] as String?,
  type: json['type'] as String?,
  setName: json['setName'] as bool?,
  name: json['name'] as String?,
  mythicPath: json['mythicPath'] as bool?,
  realityBreak: (json['realityBreak'] as num?)?.toInt(),
  perception: (json['perception'] as num?)?.toInt(),
  specialFlag: json['specialFlag'] as String?,
  memoryUnlock: json['memoryUnlock'] as String?,
  effect: json['effect'] as String?,
  consequence: json['consequence'] as String?,
  revelation: json['revelation'] as String?,
  requirement: json['requirement'] as String?,
  massiveRevelation: json['massiveRevelation'] as bool?,
  autoWin: json['autoWin'] as bool?,
  specialEvent: json['specialEvent'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ChoiceToJson(Choice instance) => <String, dynamic>{
  'text': instance.text,
  'respect': instance.respect,
  'truth': instance.truth,
  'sanity': instance.sanity,
  'money': instance.money,
  'response': instance.response,
  'type': instance.type,
  'setName': instance.setName,
  'name': instance.name,
  'mythicPath': instance.mythicPath,
  'realityBreak': instance.realityBreak,
  'perception': instance.perception,
  'specialFlag': instance.specialFlag,
  'memoryUnlock': instance.memoryUnlock,
  'effect': instance.effect,
  'consequence': instance.consequence,
  'revelation': instance.revelation,
  'requirement': instance.requirement,
  'massiveRevelation': instance.massiveRevelation,
  'autoWin': instance.autoWin,
  'specialEvent': instance.specialEvent,
};
