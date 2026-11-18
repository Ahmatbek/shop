import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app [ThemeMode] and remembers it between launches.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_read(_prefs));

  static const _key = 'theme_mode';
  final SharedPreferences _prefs;

  static ThemeMode _read(SharedPreferences prefs) =>
      switch (prefs.getString(_key)) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };

  void set(ThemeMode mode) {
    emit(mode);
    _prefs.setString(_key, mode.name);
  }
}
