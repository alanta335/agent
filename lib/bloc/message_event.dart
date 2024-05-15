part of 'message_bloc.dart';

@immutable
sealed class MessageEvent {}

final class MessageFetch extends MessageEvent {}

final class MessageClear extends MessageEvent {}

final class MessageUpdate extends MessageEvent {
  final String userPrompt;

  MessageUpdate({required this.userPrompt});
}
