import 'package:agent/model/MessageModel.dart';

class ChatCompletionResponseModel {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<ChatCompletionChoice> choices;
  final ChatCompletionUsage usage;
  final String systemFingerprint;
  final XGroq xGroq;

  ChatCompletionResponseModel({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
    required this.systemFingerprint,
    required this.xGroq,
  });

  factory ChatCompletionResponseModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> choicesJson = json['choices']; // Extract choices JSON array
    List<ChatCompletionChoice> choices = choicesJson.map((choiceJson) {
      return ChatCompletionChoice.fromJson(choiceJson);
    }).toList();

    return ChatCompletionResponseModel(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices: choices,
      usage: ChatCompletionUsage.fromJson(json['usage']),
      systemFingerprint: json['system_fingerprint'],
      xGroq: XGroq.fromJson(json['x_groq']),
    );
  }
}

class ChatCompletionChoice {
  final int index;
  final MessageModel message;

  ChatCompletionChoice({required this.index, required this.message});

  factory ChatCompletionChoice.fromJson(Map<String, dynamic> json) {
    return ChatCompletionChoice(
      index: json['index'],
      message: MessageModel.fromJson(json['message']),
    );
  }
}

class ChatCompletionUsage {
  final int promptTokens;
  final double promptTime;
  final int completionTokens;
  final double completionTime;
  final int totalTokens;
  final double totalTime;

  ChatCompletionUsage({
    required this.promptTokens,
    required this.promptTime,
    required this.completionTokens,
    required this.completionTime,
    required this.totalTokens,
    required this.totalTime,
  });

  factory ChatCompletionUsage.fromJson(Map<String, dynamic> json) {
    return ChatCompletionUsage(
      promptTokens: json['prompt_tokens'],
      promptTime: json['prompt_time'],
      completionTokens: json['completion_tokens'],
      completionTime: json['completion_time'],
      totalTokens: json['total_tokens'],
      totalTime: json['total_time'],
    );
  }
}

class XGroq {
  final String id;

  XGroq({required this.id});

  factory XGroq.fromJson(Map<String, dynamic> json) {
    return XGroq(id: json['id']);
  }
}
