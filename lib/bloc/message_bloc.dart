import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agent/Constant/enum.dart';
import 'package:agent/model/MessageModel.dart';
import 'package:agent/repository/PromptRepository.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final PromptRepository promptRepository;
  List<MessageModel> messages = [
    MessageModel(
        role: Role.system,
        content: "I am doctor."
            "I will always follow code of conduct, ethics and pledge of doctors."
            "As a doctor i will ask talk politely and friendly who asks questions to determine the disease  and recommends treatments that are safe to patients metal and physical heath.")
  ];

  MessageBloc(this.promptRepository) : super(MessageInitial()) {
    on<MessageUpdate>(_setMessage);
    on<MessageFetch>(_getPromptResponse);
    on<MessageClear>(_clearMessage);
  }

  void _clearMessage(MessageClear event, Emitter<MessageState> emit) {
    try {
      emit(
        MessageSuccess(
          message: [
            MessageModel(
                role: Role.system,
                content: "I am doctor."
                    "I will always follow code of conduct, ethics and pledge of doctors."
                    "As a doctor i will ask talk politely and friendly who asks questions to determine the disease  and recommends treatments that are safe to patients metal and physical heath.")
          ],
        ),
      );
    } catch (e) {
      emit(MessageFailure(e.toString()));
    }
  }

  void _setMessage(MessageUpdate event, Emitter<MessageState> emit) {
    try {
      messages.add(MessageModel(role: Role.user, content: event.userPrompt));
      emit(MessageSuccess(message: [...messages]));
    } catch (e) {
      emit(MessageFailure(e.toString()));
    }
  }

  void _getPromptResponse(
      MessageFetch event, Emitter<MessageState> emit) async {
    try {
      emit(MessageLoading());

      final chatCompletionResponse =
          await promptRepository.getPromptResponse(messages);

      messages.add(chatCompletionResponse.choices[0].message);

      emit(
        MessageSuccess(message: [...messages]),
      );
    } catch (e) {
      emit(MessageFailure(e.toString()));
    }
  }
}
