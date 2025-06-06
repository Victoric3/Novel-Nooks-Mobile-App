import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/features/features.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // watch providers so they don't get disposed
    // ref.watch(homeFeedNotifierProvider);

    return PopScope(
      onPopInvoked: (_) async {
        ExitModalDialog.show(context: context);
      },
      child: const ResponsiveWidget(
        smallScreen: TabsScreenSmall(),
        largeScreen: TabsScreenLarge(),
      ),
    );
  }
}
