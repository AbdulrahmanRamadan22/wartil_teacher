import 'dart:async';
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
  Timer? _autoSaveTimer;

  static const String _prefsKey = 'teacher_preferences';

  // ── Load ──────────────────────────────────────────────────────────────────
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

  // ── Toggle learning path ──────────────────────────────────────────────────
  void toggleLearningPath(String path) {
    final Map<String, int> updated =
        Map.from(_currentPreferences.learningPaths);
    if (updated.containsKey(path)) {
      updated.remove(path);
    } else {
      updated[path] = 10;
    }
    _currentPreferences = _currentPreferences.copyWith(learningPaths: updated);
    _emitAndAutoSave();
  }

  // ── Toggle age group ──────────────────────────────────────────────────────
  void toggleAgeGroup(String ageGroup) {
    final Map<String, int> updated = Map.from(_currentPreferences.ageGroups);
    if (updated.containsKey(ageGroup)) {
      updated.remove(ageGroup);
    } else {
      updated[ageGroup] = 20;
    }
    _currentPreferences = _currentPreferences.copyWith(ageGroups: updated);
    _emitAndAutoSave();
  }

  // ── Toggle student level ──────────────────────────────────────────────────
  void toggleStudentLevel(String level) {
    final Map<String, int> updated =
        Map.from(_currentPreferences.studentLevels);
    if (updated.containsKey(level)) {
      updated.remove(level);
    } else {
      updated[level] = 30;
    }
    _currentPreferences = _currentPreferences.copyWith(studentLevels: updated);
    _emitAndAutoSave();
  }

  // ── Adjust percentage ─────────────────────────────────────────────────────
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

    _emitAndAutoSave();
  }

  // ── Update work hours ─────────────────────────────────────────────────────
  void updateWorkHours(int hours) {
    _workHours = hours;
    _currentPreferences = _currentPreferences.copyWith(workHoursPerWeek: hours);
    _emitAndAutoSave();
  }

  // ── Save with confirmation (called by save button) ────────────────────────
  Future<void> savePreferences() async {
    try {
      await _persistToStorage();
      emit(AchievementPlanSuccess('تم حفظ خطة الإنجاز بنجاح ✅'));
      await Future.delayed(const Duration(seconds: 2));
      emit(AchievementPlanLoaded(_currentPreferences));
    } catch (e) {
      emit(AchievementPlanError('فشل حفظ التفضيلات: $e'));
    }
  }

  // ── Internal: emit + schedule auto-save (debounce 500ms) ─────────────────
  void _emitAndAutoSave() {
    emit(AchievementPlanLoaded(_currentPreferences));
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () async {
      await _persistToStorage();
    });
  }

  // ── Internal: write to SharedPreferences ──────────────────────────────────
  Future<void> _persistToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String prefsJson = jsonEncode(_currentPreferences.toJson());
    await prefs.setString(_prefsKey, prefsJson);
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  TeacherPreferences get currentPreferences => _currentPreferences;
  int get workHours => _workHours;

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }
}

