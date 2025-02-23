import 'package:auto_route/auto_route.dart';
import 'package:eulaiq/src/common/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:eulaiq/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:ui';

@RoutePage()
class TabsScreenSmall extends ConsumerWidget {
  const TabsScreenSmall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        LibraryRoute(),
        ScheduleRoute(),
        CreateRoute(),
        CommunityRoute(),
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          extendBody: true, // Make body extend behind bottom nav
          bottomNavigationBar: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.bottomNavigationBarTheme.backgroundColor?.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: BottomNavigationBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
                  unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
                  showUnselectedLabels: true,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  items: <BottomNavigationBarItem>[
                    _buildNavItem(MdiIcons.homeVariant, 'Home', tabsRouter.activeIndex == 0),
                    _buildNavItem(MdiIcons.bookshelf, 'Library', tabsRouter.activeIndex == 1),
                    _buildNavItem(MdiIcons.plusCircle, 'Create', tabsRouter.activeIndex == 2, isCreate: true),
                    _buildNavItem(MdiIcons.calendarText, 'Schedule', tabsRouter.activeIndex == 3),
                    _buildNavItem(MdiIcons.accountGroup, 'Community', tabsRouter.activeIndex == 4),
                  ],
                  currentIndex: tabsRouter.activeIndex,
                  onTap: tabsRouter.setActiveIndex,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, bool isActive, {bool isCreate = false}) {
    return BottomNavigationBarItem(
      icon: Container(
        height: 32,
        width: 32,
        margin: const EdgeInsets.only(bottom: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: isCreate ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.neonCyan, AppColors.neonPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ) : null,
          child: Icon(
            icon,
            size: isActive ? 26 : 22,
            color: isCreate ? Colors.white : null,
          ),
        ),
      ),
      label: label,
    );
  }
}
