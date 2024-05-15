import 'package:agent/model/MessageModel.dart';

class ChatCompletionRequestModel {
  List<MessageModel> messages;
  String model;
  double temperature;
  int maxTokens;
  double topP;
  bool stream;
  dynamic stop;
  ChatCompletionRequestModel({
    required this.messages,
    required this.model,
    required this.temperature,
    required this.maxTokens,
    required this.topP,
    required this.stream,
    this.stop,
  });

  factory ChatCompletionRequestModel.fromJson(Map<String, dynamic> json) {
    return ChatCompletionRequestModel(
      messages: json['messages']
          .map((message) => MessageModel.fromJson(message))
          .toList(),
      model: json['model'],
      temperature: json['temperature'],
      maxTokens: json['maxTokens'],
      topP: json['top_p'],
      stream: json['stream'],
      stop: json['stop'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
      'model': model,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'top_p': topP,
      'stream': stream,
      'stop': stop,
    };
  }
}
