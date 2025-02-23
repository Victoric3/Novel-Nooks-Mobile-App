import 'package:flutter/material.dart';
import 'package:eulaiq/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logman/logman.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Remove the incorrect cast
    final _appRouter = AppRouter();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ref.watch(currentAppThemeNotifierProvider).when(
        data: (theme) => themeData(theme == CurrentAppTheme.dark ? darkTheme : lightTheme),
        loading: () => themeData(lightTheme),
        error: (_, __) => themeData(lightTheme),
      ),
      darkTheme: themeData(darkTheme),
      themeMode: ref.watch(currentAppThemeNotifierProvider)
          .whenData((theme) => theme.themeMode)
          .value ?? ThemeMode.system,
      routerConfig: _appRouter.config(
        navigatorObservers: () => [
          LogmanNavigatorObserver(),
        ],
      ),
    );
  }

  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.sourceSansProTextTheme(
        theme.textTheme,
      ),
      colorScheme: theme.colorScheme.copyWith(
        secondary: lightAccent,
      ),
    );
  }
}
