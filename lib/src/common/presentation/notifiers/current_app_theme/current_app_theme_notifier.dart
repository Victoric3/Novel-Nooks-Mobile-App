import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_app_theme_notifier.g.dart';

@riverpod
class CurrentAppThemeNotifier extends _$CurrentAppThemeNotifier {
  late CurrentAppThemeService _currentAppThemeService;

  CurrentAppThemeNotifier() : super();

  // Add method to change to system theme
  Future<void> useSystemTheme() async {
    final success = await _currentAppThemeService.setCurrentAppTheme(CurrentAppTheme.system);
    if (success) {
      state = const AsyncValue.data(CurrentAppTheme.system);
    }
  }

  // Update this method to accept CurrentAppTheme instead of bool
  Future<void> updateCurrentAppTheme(CurrentAppTheme theme) async {
    final success = await _currentAppThemeService.setCurrentAppTheme(theme);
    if (success) {
      state = AsyncValue.data(theme);
    }
  }

  @override
  Future<CurrentAppTheme> build() async {
    _currentAppThemeService = ref.read(currentAppThemeServiceProvider);
    return _currentAppThemeService.getCurrentAppTheme();
  }
}

enum CurrentAppTheme {
  light(ThemeMode.light),
  dark(ThemeMode.dark),
  system(ThemeMode.system);  // Add this line

  final ThemeMode themeMode;
  const CurrentAppTheme(this.themeMode);
}
