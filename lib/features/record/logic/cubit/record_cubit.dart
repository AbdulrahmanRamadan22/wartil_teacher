import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waratel_app/features/record/logic/cubit/record_state.dart';
import 'package:waratel_app/features/record/data/models/session_model.dart';

class RecordCubit extends Cubit<RecordState> {
  RecordCubit() : super(RecordInitial()) {
    loadSessions();
  }

  List<SessionModel> _sessions = [];
  bool showCompletedCalls = true;

  static const String _prefsKey = 'session_records';

  Future<void> loadSessions() async {
    try {
      emit(RecordLoading());
      final prefs = await SharedPreferences.getInstance();
      final List<String>? sessionsJson = prefs.getStringList(_prefsKey);

      if (sessionsJson != null) {
        _sessions = [];
        for (var sessionString in sessionsJson) {
          try {
            final decoded = jsonDecode(sessionString);
            _sessions.add(SessionModel.fromJson(decoded));
          } catch (e) {
            // Skip corrupt record
          }
        }
      }

      emit(RecordLoaded(_sessions));
    } catch (e) {
      emit(RecordError('فشل تحميل السجلات: $e'));
    }
  }

  Future<void> addSession(SessionModel session) async {
    try {
      _sessions.insert(0, session); // Add to top
      if (!isClosed) {
        emit(RecordLoaded(List.from(_sessions))); // Emit new list reference
      }

      final prefs = await SharedPreferences.getInstance();
      final List<String> sessionsJson =
          _sessions.map((e) => jsonEncode(e.toJson())).toList();

      await prefs.setStringList(_prefsKey, sessionsJson);
    } catch (e) {
      // print('Error saving session: $e');
      emit(RecordError('فشل حفظ السجل: $e'));
    }
  }

  void changeFilter(bool completed) {
    showCompletedCalls = completed;
    // Filter logic can be implemented here if needed,
    // for now just updating the flag and re-emitting current sessions if loaded
    if (state is RecordLoaded) {
      emit(RecordLoaded(_sessions));
    } else {
      emit(RecordFilterChangedState(showCompletedCalls));
    }
  }
}
