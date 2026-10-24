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

  static const Map<String, String> _aliases = {
    'تلقين': 'talqin',
    'talqin': 'talqin',
    'تلاوة': 'tilawat',
    'tilawat': 'tilawat',
    'تسميع': 'tasmie',
    'tasmie': 'tasmie',
    'إقراء وإجازة': 'iqra_ijaza',
    'iqra_ijaza': 'iqra_ijaza',
    'مبتدئ': 'beginner',
    'beginner': 'beginner',
    'متوسط': 'intermediate',
    'intermediate': 'intermediate',
    'متقدم': 'advanced',
    'advanced': 'advanced',
    '5-12': '5-12',
    '13-59': '13-59',
    '+60': '+60',
  };

  String? _findMatchingKey(Map<String, int> map, String key) {
    if (map.containsKey(key)) return key;
    final canonical = _aliases[key];
    if (canonical != null) {
      for (final k in map.keys) {
        if (k == canonical || _aliases[k] == canonical) return k;
      }
    }
    return null;
  }

  // ── Toggle learning path ──────────────────────────────────────────────────
  void toggleLearningPath(String path) {
    final Map<String, int> updated =
        Map.from(_currentPreferences.learningPaths);
    final existingKey = _findMatchingKey(updated, path);
    if (existingKey != null) {
      updated.remove(existingKey);
    } else {
      final keyToAdd = _aliases[path] ?? path;
      updated[keyToAdd] = 20;
    }
    _currentPreferences = _currentPreferences.copyWith(learningPaths: updated);
    _emitAndAutoSave();
  }

  // ── Toggle age group ──────────────────────────────────────────────────────
  void toggleAgeGroup(String ageGroup) {
    final Map<String, int> updated = Map.from(_currentPreferences.ageGroups);
    final existingKey = _findMatchingKey(updated, ageGroup);
    if (existingKey != null) {
      updated.remove(existingKey);
    } else {
      final keyToAdd = _aliases[ageGroup] ?? ageGroup;
      updated[keyToAdd] = 20;
    }
    _currentPreferences = _currentPreferences.copyWith(ageGroups: updated);
    _emitAndAutoSave();
  }

  // ── Toggle student level ──────────────────────────────────────────────────
  void toggleStudentLevel(String level) {
    final Map<String, int> updated =
        Map.from(_currentPreferences.studentLevels);
    final existingKey = _findMatchingKey(updated, level);
    if (existingKey != null) {
      updated.remove(existingKey);
    } else {
      final keyToAdd = _aliases[level] ?? level;
      updated[keyToAdd] = 20;
    }
    _currentPreferences = _currentPreferences.copyWith(studentLevels: updated);
    _emitAndAutoSave();
  }

  // ── Adjust percentage ─────────────────────────────────────────────────────
  void adjustPercentage(String category, String key, int delta) {
    Map<String, int> updated;

    if (category == 'learningPaths') {
      updated = Map.from(_currentPreferences.learningPaths);
      final existingKey = _findMatchingKey(updated, key) ?? (_aliases[key] ?? key);
      final currentVal = updated[existingKey] ?? 0;
      updated[existingKey] = (currentVal + delta).clamp(0, 100);
      _currentPreferences =
          _currentPreferences.copyWith(learningPaths: updated);
    } else if (category == 'ageGroups') {
      updated = Map.from(_currentPreferences.ageGroups);
      final existingKey = _findMatchingKey(updated, key) ?? (_aliases[key] ?? key);
      final currentVal = updated[existingKey] ?? 0;
      updated[existingKey] = (currentVal + delta).clamp(0, 100);
      _currentPreferences = _currentPreferences.copyWith(ageGroups: updated);
    } else if (category == 'studentLevels') {
      updated = Map.from(_currentPreferences.studentLevels);
      final existingKey = _findMatchingKey(updated, key) ?? (_aliases[key] ?? key);
      final currentVal = updated[existingKey] ?? 0;
      updated[existingKey] = (currentVal + delta).clamp(0, 100);
      _currentPreferences =
          _currentPreferences.copyWith(studentLevels: updated);
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

