import 'package:json_annotation/json_annotation.dart';
import 'choice.dart';

part 'scene.g.dart';

@JsonSerializable()
class Scene {
  final String id;
  final String? location;
  final String? date;
  final String? background;
  final String? music;
  final String? narration;
  final String? description;
  final String? autoContinue;
  final List<Choice>? choices;
  final Map<String, dynamic>? scarlettAppears;
  final String? scarlettDialogue;
  final bool? criticalMoment;
  final Map<String, dynamic>? pastVersionsAppear;
  
  Scene({
    required this.id,
    this.location,
    this.date,
    this.background,
    this.music,
    this.narration,
    this.description,
    this.autoContinue,
    this.choices,
    this.scarlettAppears,
    this.scarlettDialogue,
    this.criticalMoment,
    this.pastVersionsAppear,
  });

  factory Scene.fromJson(Map<String, dynamic> json) =>
      _$SceneFromJson(json);

  Map<String, dynamic> toJson() => _$SceneToJson(this);
}
