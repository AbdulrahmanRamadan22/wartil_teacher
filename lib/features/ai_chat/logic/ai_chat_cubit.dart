import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../data/models/chat_message.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  final String apiKey;
  final Dio _dio = Dio();
  final String _model = 'llama-3.3-70b-versatile';
  final String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  AiChatCubit(this.apiKey) : super(const AiChatInitial());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(userMessage);
    emit(AiChatUpdated(messages: updatedMessages, isTyping: true));

    try {
      final List<Map<String, String>> history = [
        {
          'role': 'system',
          'content':
              'أنت مساعد ذكي لتطبيق "ورتل" (Wrattel). تطبيق ورتل هو تطبيق لتعليم القرآن الكريم وتجويده. ساعد المستخدمين في استفساراتهم حول التطبيق أو القرآن الكريم بأسلوب مهذب وودود باللغة العربية. اجعل إجاباتك مختصرة ومفيدة.'
        },
        ...updatedMessages.map((m) => {
              'role': m.sender == MessageSender.user ? 'user' : 'assistant',
              'content': m.text,
            }),
      ];

      final response = await _dio.post(
        _baseUrl,
        data: {
          'model': _model,
          'messages': history,
          'stream': true,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
      );

      final assistantMessage = ChatMessage(
        text: '',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      final streamingMessages = List<ChatMessage>.from(updatedMessages)
        ..add(assistantMessage);
      String fullResponseText = '';

      final Stream<List<int>> stream = response.data.stream;

      await for (final chunk in stream) {
        final String decoded = utf8.decode(chunk);
        final List<String> lines = decoded.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final String dataText = line.substring(6).trim();
            if (dataText == '[DONE]') break;

            try {
              final Map<String, dynamic> json = jsonDecode(dataText);
              final String content =
                  json['choices'][0]['delta']['content'] ?? '';
              fullResponseText += content;

              if (content.isNotEmpty) {
                streamingMessages[streamingMessages.length - 1] =
                    assistantMessage.copyWith(text: fullResponseText);
                emit(AiChatUpdated(
                    messages: List.from(streamingMessages), isTyping: true));
              }
            } catch (_) {
              // Ignore invalid JSON chunks
            }
          }
        }
      }

      emit(AiChatUpdated(messages: streamingMessages, isTyping: false));
    } catch (e) {
      String errorMessage = 'حدث خطأ في الاتصال. يرجى التأكد من مفتاح API.';

      if (e is DioException) {
        if (e.response?.statusCode == 429) {
          errorMessage =
              'تم تجاوز حد الطلبات المسموح به حالياً. يرجى المحاولة بعد لحظات.';
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'مفتاح API غير صالح.';
        }
      }

      emit(AiChatError(message: errorMessage, messages: state.messages));
    }
  }

  void clearChat() {
    emit(const AiChatInitial());
  }
}
