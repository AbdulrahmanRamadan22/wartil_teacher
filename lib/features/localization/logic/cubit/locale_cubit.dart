import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waratel_app/features/localization/logic/cubit/locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleInitial());

  static const String _localeKey = 'app_locale';

  Future<void> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedLanguageCode = prefs.getString(_localeKey);

    if (cachedLanguageCode != null) {
      emit(ChangeLocaleState(locale: Locale(cachedLanguageCode)));
    } else {
      // Default to Arabic
      emit(ChangeLocaleState(locale: const Locale('ar')));
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    emit(ChangeLocaleState(locale: Locale(languageCode)));
  }
}
