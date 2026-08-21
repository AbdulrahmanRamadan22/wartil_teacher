import 'package:equatable/equatable.dart';
import '../data/models/chat_message.dart';

abstract class AiChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isTyping;

  const AiChatState({required this.messages, this.isTyping = false});

  @override
  List<Object?> get props => [messages, isTyping];
}

class AiChatInitial extends AiChatState {
  const AiChatInitial() : super(messages: const []);
}

class AiChatUpdated extends AiChatState {
  const AiChatUpdated({required super.messages, super.isTyping});
}

class AiChatError extends AiChatState {
  final String message;
  const AiChatError({required this.message, required super.messages});

  @override
  List<Object?> get props => [message, ...super.props];
}
