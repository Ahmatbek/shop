import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Set of favorite product ids, persisted locally.
class FavoritesCubit extends Cubit<Set<int>> {
  FavoritesCubit([this._prefs]) : super(_read(_prefs));

  static const _key = 'favorite_ids';
  final SharedPreferences? _prefs;

  static Set<int> _read(SharedPreferences? prefs) =>
      (prefs?.getStringList(_key) ?? const <String>[]).map(int.parse).toSet();

  void toggle(int productId) {
    final next = {...state};
    if (!next.remove(productId)) next.add(productId);
    emit(next);
    _prefs?.setStringList(_key, next.map((e) => '$e').toList());
  }
}
