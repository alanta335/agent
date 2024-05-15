import 'package:agent/Constant/enum.dart';

class MessageModel {
  Role role;
  String content;

  MessageModel({required this.role, required this.content});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      role: _roleFromString(json['role']),
      content: json['content'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'role': role.toString().split('.').last,
      'content': content,
    };
  }

  static Role _roleFromString(String roleString) {
    switch (roleString) {
      case 'system':
        return Role.system;
      case 'user':
        return Role.user;
      case 'assistant':
        return Role.assistant;
      default:
        throw Exception('Invalid role: $roleString');
    }
  }
}
