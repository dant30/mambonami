import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/local/cache_manager.dart';
import '../../core/constants.dart';

class LocaleState {
  final Locale locale;

  LocaleState(this.locale);
}

class LocaleCubit extends Cubit<LocaleState> {
  static const supportedLocales = [Locale('en'), Locale('sw')];

  LocaleCubit() : super(LocaleState(const Locale('en'))) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final storedValue = await CacheManager.instance.getString(kAppLocaleKey);
    final locale = _localeFromCode(storedValue);
    emit(LocaleState(locale));
  }

  Future<void> setLocale(Locale locale) async {
    await CacheManager.instance.saveString(kAppLocaleKey, locale.languageCode);
    emit(LocaleState(locale));
  }

  Locale _localeFromCode(String? code) {
    if (code == null) return const Locale('en');
    final supported = supportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => const Locale('en'),
    );
    return supported;
  }
}
