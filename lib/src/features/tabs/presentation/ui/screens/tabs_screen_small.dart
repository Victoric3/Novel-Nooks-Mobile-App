import 'package:auto_route/auto_route.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:ui';
import 'package:novelnooks/src/features/library/presentation/providers/featured_book_provider.dart';
import 'package:novelnooks/src/common/widgets/featured_book_overlay.dart';

@RoutePage()
class TabsScreenSmall extends ConsumerWidget {
  const TabsScreenSmall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Request the featured book when tab screen initializes 
    // (only if not done already or if we need to refresh)
    Future.microtask(() {
      final featuredState = ref.read(featuredBookProvider);
      if (featuredState.featuredBook == null && !featuredState.isLoading) {
        ref.read(featuredBookProvider.notifier).fetchRandomFeaturedBook();
      }
    });
    
    return AutoTabsRouter(
      // Update routes to include Explore and rename Explore to Library
      routes: const [
        HomeRoute(),
        ExploreRoute(), // New Explore tab
        CreateBookRoute(),
        LibraryRoute(), // Previously named "Explore"
        MeRoute(),
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Stack(
          children: [
            // Main scaffold with bottom navigation
            Scaffold(
              body: child,
              extendBody: true, // Make body extend behind bottom nav
              bottomNavigationBar: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                AppColors.darkBg.withOpacity(0.85),
                                AppColors.darkBg.withOpacity(0.95),
                              ]
                            : [
                                Colors.white.withOpacity(0.85),
                                Colors.white.withOpacity(0.95),
                              ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? AppColors.neonCyan.withOpacity(0.1)
                              : AppColors.brandDeepGold.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, -2),
                        )
                      ],
                    ),
                    child: BottomNavigationBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: isDark 
                        ? AppColors.neonCyan 
                        : AppColors.brandDeepGold,
                      unselectedItemColor: isDark
                        ? Colors.white.withOpacity(0.5)
                        : AppColors.neutralDarkGray.withOpacity(0.5),
                      showUnselectedLabels: true,
                      selectedFontSize: 11,
                      unselectedFontSize: 11,
                      items: <BottomNavigationBarItem>[
                        _buildNavItem(MdiIcons.homeVariant, 'Home', tabsRouter.activeIndex == 0, isDark),
                        _buildNavItem(MdiIcons.tagMultiple, 'Explore', tabsRouter.activeIndex == 1, isDark), // New Explore tab with tag icon
                        _buildNavItem(MdiIcons.plusCircle, 'Create', tabsRouter.activeIndex == 2, isDark), 
                        _buildNavItem(MdiIcons.bookshelf, 'Library', tabsRouter.activeIndex == 3, isDark), // Renamed Explore to Library with bookshelf icon
                        _buildNavItem(MdiIcons.account, 'Me', tabsRouter.activeIndex == 4, isDark),
                      ],
                      currentIndex: tabsRouter.activeIndex,
                      onTap: tabsRouter.setActiveIndex,
                    ),
                  ),
                ),
              ),
            ),
            
            // Featured book overlay with proper router context
            Consumer(
              builder: (context, ref, _) {
                final featuredState = ref.watch(featuredBookProvider);
                
                if (featuredState.featuredBook != null) {
                  return FeaturedBookOverlay(
                    book: featuredState.featuredBook!, 
                    onDismiss: () {
                      ref.read(featuredBookProvider.notifier).clearFeaturedBook();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, bool isActive, bool isDark) {
    return BottomNavigationBarItem(
      icon: Container(
        height: 32,
        width: 32,
        margin: const EdgeInsets.only(bottom: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: isActive ? BoxDecoration(
            color: isDark
                ? AppColors.neonCyan.withOpacity(0.15)
                : AppColors.brandDeepGold.withOpacity(0.15),
            shape: BoxShape.circle,
          ) : null,
          child: Icon(
            icon,
            size: isActive ? 24 : 20,
            color: isActive
                ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                : null,
          ),
        ),
      ),
      label: label,
    );
  }
}
