import 'package:flutter/material.dart';

abstract class LocaleState {}

class LocaleInitial extends LocaleState {}

class ChangeLocaleState extends LocaleState {
  final Locale locale;
  ChangeLocaleState({required this.locale});
}
