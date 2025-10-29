// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scene _$SceneFromJson(Map<String, dynamic> json) => Scene(
  id: json['id'] as String,
  location: json['location'] as String?,
  date: json['date'] as String?,
  background: json['background'] as String?,
  music: json['music'] as String?,
  narration: json['narration'] as String?,
  description: json['description'] as String?,
  autoContinue: json['autoContinue'] as String?,
  choices: (json['choices'] as List<dynamic>?)
      ?.map((e) => Choice.fromJson(e as Map<String, dynamic>))
      .toList(),
  scarlettAppears: json['scarlettAppears'] as Map<String, dynamic>?,
  scarlettDialogue: json['scarlettDialogue'] as String?,
  criticalMoment: json['criticalMoment'] as bool?,
  pastVersionsAppear: json['pastVersionsAppear'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SceneToJson(Scene instance) => <String, dynamic>{
  'id': instance.id,
  'location': instance.location,
  'date': instance.date,
  'background': instance.background,
  'music': instance.music,
  'narration': instance.narration,
  'description': instance.description,
  'autoContinue': instance.autoContinue,
  'choices': instance.choices,
  'scarlettAppears': instance.scarlettAppears,
  'scarlettDialogue': instance.scarlettDialogue,
  'criticalMoment': instance.criticalMoment,
  'pastVersionsAppear': instance.pastVersionsAppear,
};
