import 'package:flutter/material.dart';
import 'package:eulaiq/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(currentAppThemeNotifierProvider).value ==
        CurrentAppTheme.dark;
    return Scaffold(
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Change Theme to ${isDarkMode ? 'Light' : 'Dark'}'),
            onTap: () {
              ref
                  .read(currentAppThemeNotifierProvider.notifier)
                  .updateCurrentAppTheme(!isDarkMode);
            },
          ),
        ],
      ),
    );
  }
}
