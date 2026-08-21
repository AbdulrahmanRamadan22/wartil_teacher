import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'achievement_plan_state.dart';
import '../../data/models/teacher_preferences.dart';

class AchievementPlanCubit extends Cubit<AchievementPlanState> {
  AchievementPlanCubit() : super(AchievementPlanInitial()) {
    loadPreferences();
  }

  TeacherPreferences _currentPreferences = TeacherPreferences.empty();
  int _workHours = 0;

  static const String _prefsKey = 'teacher_preferences';

  Future<void> loadPreferences() async {
    try {
      emit(AchievementPlanLoading());
      final prefs = await SharedPreferences.getInstance();
      final String? prefsJson = prefs.getString(_prefsKey);

      if (prefsJson != null) {
        final Map<String, dynamic> json = jsonDecode(prefsJson);
        _currentPreferences = TeacherPreferences.fromJson(json);
        _workHours = _currentPreferences.workHoursPerWeek;
      }

      emit(AchievementPlanLoaded(_currentPreferences));
    } catch (e) {
      emit(AchievementPlanError('فشل تحميل التفضيلات: $e'));
    }
  }

  void toggleLearningPath(String path) {
    final Map<String, int> updated =
        Map.from(_currentPreferences.learningPaths);
    if (updated.containsKey(path)) {
      updated.remove(path);
    } else {
      updated[path] = 10; // Default percentage
    }
    _currentPreferences = _currentPreferences.copyWith(learningPaths: updated);
    emit(AchievementPlanLoaded(_currentPreferences));
  }

  void toggleAgeGroup(String ageGroup) {
    final Map<String, int> updated = Map.from(_currentPreferences.ageGroups);
    if (updated.containsKey(ageGroup)) {
      updated.remove(ageGroup);
    } else {
      updated[ageGroup] = 20; // Default percentage
    }
    _currentPreferences = _currentPreferences.copyWith(ageGroups: updated);
    emit(AchievementPlanLoaded(_currentPreferences));
  }

  void toggleStudentLevel(String level) {
    final Map<String, int> updated =
        Map.from(_currentPreferences.studentLevels);
    if (updated.containsKey(level)) {
      updated.remove(level);
    } else {
      updated[level] = 30; // Default percentage
    }
    _currentPreferences = _currentPreferences.copyWith(studentLevels: updated);
    emit(AchievementPlanLoaded(_currentPreferences));
  }

  void adjustPercentage(String category, String key, int delta) {
    Map<String, int> updated;

    if (category == 'learningPaths') {
      updated = Map.from(_currentPreferences.learningPaths);
      if (updated.containsKey(key)) {
        updated[key] = (updated[key]! + delta).clamp(0, 100);
        _currentPreferences =
            _currentPreferences.copyWith(learningPaths: updated);
      }
    } else if (category == 'ageGroups') {
      updated = Map.from(_currentPreferences.ageGroups);
      if (updated.containsKey(key)) {
        updated[key] = (updated[key]! + delta).clamp(0, 100);
        _currentPreferences = _currentPreferences.copyWith(ageGroups: updated);
      }
    } else if (category == 'studentLevels') {
      updated = Map.from(_currentPreferences.studentLevels);
      if (updated.containsKey(key)) {
        updated[key] = (updated[key]! + delta).clamp(0, 100);
        _currentPreferences =
            _currentPreferences.copyWith(studentLevels: updated);
      }
    }

    emit(AchievementPlanLoaded(_currentPreferences));
  }

  void updateWorkHours(int hours) {
    _workHours = hours;
    _currentPreferences = _currentPreferences.copyWith(workHoursPerWeek: hours);
    emit(AchievementPlanLoaded(_currentPreferences));
  }

  Future<void> savePreferences() async {
    try {
      emit(AchievementPlanLoading());
      final prefs = await SharedPreferences.getInstance();
      final String prefsJson = jsonEncode(_currentPreferences.toJson());
      await prefs.setString(_prefsKey, prefsJson);

      emit(AchievementPlanSuccess('تم حفظ التفضيلات بنجاح'));
      // Return to loaded state after showing success
      await Future.delayed(const Duration(seconds: 1));
      emit(AchievementPlanLoaded(_currentPreferences));
    } catch (e) {
      emit(AchievementPlanError('فشل حفظ التفضيلات: $e'));
    }
  }

  TeacherPreferences get currentPreferences => _currentPreferences;
  int get workHours => _workHours;
}
