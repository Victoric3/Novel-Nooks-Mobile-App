import 'package:auto_route/auto_route.dart';
import 'package:novelnooks/src/common/router/auth_guard.dart';
import 'package:novelnooks/src/features/Me/me.dart';
import 'package:novelnooks/src/features/auth/blocs/verify_code.dart';
import 'package:novelnooks/src/features/auth/screens/auth_screen.dart';
import 'package:novelnooks/src/features/auth/screens/intro_page.dart';
import 'package:novelnooks/src/features/auth/screens/reset_password_screen.dart';
import 'package:novelnooks/src/features/auth/screens/verification_code_screen.dart';
import 'package:novelnooks/src/features/create/presentation/ui/screens/create_book_screen.dart';
import 'package:novelnooks/src/features/create/presentation/ui/screens/edit_book_screen.dart';
import 'package:novelnooks/src/features/home/presentation/ui/screens/search_screen.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';
import 'package:novelnooks/src/features/library/presentation/ui/screens/ebook_detail_screen.dart';
import 'package:novelnooks/src/features/notifications/presentation/ui/screens/notifications_screen.dart';
import 'package:novelnooks/src/features/reader/presentation/ui/screens/reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:novelnooks/src/features/features.dart';
import 'package:novelnooks/src/features/explore/presentation/ui/screens/explore_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: '/',
      page: SplashRoute.page,
      initial: true,
      guards: [AuthGuard()],
    ),
    AutoRoute(path: '/auth', page: AuthRoute.page),
    AutoRoute(path: '/signin', page: SignInRoute.page),
    AutoRoute(path: '/signup', page: SignUpRoute.page),
    AutoRoute(path: '/intro', page: IntroRoute.page),
    AutoRoute(path: '/home', page: HomeRoute.page, guards: [AuthGuard()]),
    AutoRoute(
      path: '/library',
      page: LibraryRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/search',
      page: SearchRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/notifications',
      page: NotificationsRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/create',
      page: CreateBookRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/reader/:storyId',
      page: ReaderRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(path: '/verify', page: VerificationCodeRoute.page),
    AutoRoute(path: '/reset-password', page: ResetPasswordRoute.page),
    AutoRoute(
      path: '/ebook/:id',
      page: EbookDetailRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/edit-book',
      page: EditBookRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: ExploreRoute.page,
      path: '/explore',
    ),
    CustomRoute(
      page: TabsRoute.page,
      path: '/tabs',
      transitionsBuilder:
          (_, animation, ___, child) =>
              FadeTransition(opacity: animation, child: child),
      children: <AutoRoute>[
        RedirectRoute(path: '', redirectTo: 'home'),
        AutoRoute(page: HomeRoute.page, path: 'home'),
        AutoRoute(page: ExploreRoute.page, path: 'explore'),
        AutoRoute(page: CreateBookRoute.page, path: 'create'),
        AutoRoute(page: LibraryRoute.page, path: 'library'),
        AutoRoute(page: MeRoute.page, path: 'me'),
      ],
    ),
  ];
}
