import 'package:agent/model/ChatCompletionResponseModel.dart';
import 'package:agent/model/MessageModel.dart';
import 'package:agent/service/PromptDataProvider.dart';

class PromptRepository {
  final PromptDataProvider promptDataProvider;
  PromptRepository(this.promptDataProvider);
  Future<ChatCompletionResponseModel> getPromptResponse(
      List<MessageModel> messages) async {
    final response = await promptDataProvider.getPromptResponse(messages);
    print(response);
    try {
      return ChatCompletionResponseModel.fromJson(response);
    } catch (e) {
      throw e.toString();
    }
  }
}
