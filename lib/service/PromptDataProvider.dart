import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:agent/model/ChatCompletionRequestModel.dart';
import 'package:agent/model/MessageModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PromptDataProvider {
  final Dio dio = Dio();

  Future<Map<String, dynamic>> getPromptResponse(
      List<MessageModel> messages) async {
    String url = dotenv.env['URL'] as String;
    String apiKey = dotenv.env['API_KEY'] as String;
    const String model = "llama3-8b-8192";
    const double temperature = 1;
    const int maxTokens = 1024;
    const double topP = 1;
    const bool stream = false;

    dio.options.headers = {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json",
    };

    final ChatCompletionRequestModel body = ChatCompletionRequestModel(
      messages: messages,
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
      topP: topP,
      stream: stream,
    );

    try {
      final response = await dio.post(
        url,
        data: jsonEncode(body),
      );
      return response.data;
    } catch (e) {
      print("Request failed with error: $e");
      throw e.toString();
    }
  }
}
// List<Message> messages = [
//   Message(
//       role: Role.system,
//       content:
//           "i am doctor.\ni will always follow code of conduct, ethics and pledge of doctors.\nAs a doctor i will ask talk politely and friendly who asks questions to determine the disease  and recommends treatments that are safe to patients metal and physical heath.")
// ];
