import 'package:flutter/foundation.dart';

@immutable
class AiMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> references;
  final List<String> suggestedFollowUps;

  const AiMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.references = const [],
    this.suggestedFollowUps = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'references': references,
        'suggestedFollowUps': suggestedFollowUps,
      };

  factory AiMessage.fromJson(Map<String, dynamic> json) => AiMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
        references: (json['references'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        suggestedFollowUps: (json['suggestedFollowUps'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}
