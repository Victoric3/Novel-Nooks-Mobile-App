import 'package:novelnooks/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Add this with your other constants
const String themePreferenceKey = 'theme_preference_key';

class CurrentAppThemeService {
  final SharedPreferences? _sharedPreferences;

  const CurrentAppThemeService(this._sharedPreferences);

  Future<bool> setCurrentAppTheme(CurrentAppTheme theme) =>
      _sharedPreferences!.setString(
        themePreferenceKey,
        theme.toString(),
      );

  CurrentAppTheme getCurrentAppTheme() {
    final themeStr = _sharedPreferences!.getString(themePreferenceKey);
    
    // If no theme is set, return system as default
    if (themeStr == null) {
      return CurrentAppTheme.system;
    }
    
    // Otherwise return the saved theme
    try {
      return CurrentAppTheme.values.firstWhere(
        (e) => e.toString() == themeStr,
        orElse: () => CurrentAppTheme.system,
      );
    } catch (e) {
      return CurrentAppTheme.system;
    }
  }

  bool getIsDarkMode() {
    final isDarkMode = _sharedPreferences!.getBool(isDarkModeKey);
    return isDarkMode ?? false;
  }
}

final currentAppThemeServiceProvider = Provider<CurrentAppThemeService>(
  (ref) {
    return CurrentAppThemeService(ref.watch(sharedPreferencesProvider));
  },
);
