part of 'message_bloc.dart';

@immutable
sealed class MessageState {}

final class MessageInitial extends MessageState {}

final class MessageSuccess extends MessageState {
  final List<MessageModel> message;

  MessageSuccess({required this.message});
}

final class MessageFailure extends MessageState {
  final String error;
  MessageFailure(this.error);
}

final class MessageLoading extends MessageState {}
