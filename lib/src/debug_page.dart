import 'package:flutter/material.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentAppThemeNotifierProvider).value;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Options'),
      ),
      body: ListView(
        children: <Widget>[
          // Theme options
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Theme Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          RadioListTile<CurrentAppTheme>(
            title: const Text('System Theme'),
            value: CurrentAppTheme.system,
            groupValue: currentTheme,
            onChanged: (value) {
              ref
                  .read(currentAppThemeNotifierProvider.notifier)
                  .updateCurrentAppTheme(CurrentAppTheme.system);
            },
          ),
          RadioListTile<CurrentAppTheme>(
            title: const Text('Light Theme'),
            value: CurrentAppTheme.light,
            groupValue: currentTheme,
            onChanged: (value) {
              ref
                  .read(currentAppThemeNotifierProvider.notifier)
                  .updateCurrentAppTheme(CurrentAppTheme.light);
            },
          ),
          RadioListTile<CurrentAppTheme>(
            title: const Text('Dark Theme'),
            value: CurrentAppTheme.dark,
            groupValue: currentTheme,
            onChanged: (value) {
              ref
                  .read(currentAppThemeNotifierProvider.notifier)
                  .updateCurrentAppTheme(CurrentAppTheme.dark);
            },
          ),
          
          const Divider(),
          
          // Other debug options can be added here
        ],
      ),
    );
  }
}
