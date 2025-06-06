// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter();

  @override
  final Map<String, PageFactory> pagesMap = {
    AuthRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AuthScreen(),
      );
    },
    CreateBookRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CreateBookScreen(),
      );
    },
    EbookDetailRoute.name: (routeData) {
      final args = routeData.argsAs<EbookDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: EbookDetailScreen(
          key: args.key,
          id: args.id,
          slug: args.slug,
          ebook: args.ebook,
        ),
      );
    },
    EditBookRoute.name: (routeData) {
      final args = routeData.argsAs<EditBookRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: EditBookScreen(
          key: args.key,
          ebookToEdit: args.ebookToEdit,
        ),
      );
    },
    ExploreRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ExploreScreen(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    IntroRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const IntroScreen(),
      );
    },
    LibraryRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LibraryScreen(),
      );
    },
    MeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MeScreen(),
      );
    },
    NotificationsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NotificationsScreen(),
      );
    },
    ReaderRoute.name: (routeData) {
      final args = routeData.argsAs<ReaderRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ReaderScreen(
          key: args.key,
          storyId: args.storyId,
          title: args.title,
          isFree: args.isFree,
          contentCount: args.contentCount,
          pricePerChapter: args.pricePerChapter,
          completed: args.completed,
        ),
      );
    },
    ResetPasswordRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ResetPasswordScreen(),
      );
    },
    SearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SearchScreen(),
      );
    },
    SignInRoute.name: (routeData) {
      final args = routeData.argsAs<SignInRouteArgs>(
          orElse: () => const SignInRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SignInScreen(key: args.key),
      );
    },
    SignUpRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SignUpScreen(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
    TabsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TabsScreen(),
      );
    },
    TabsRouteSmall.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TabsScreenSmall(),
      );
    },
    VerificationCodeRoute.name: (routeData) {
      final args = routeData.argsAs<VerificationCodeRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: VerificationCodeScreen(
          verificationType: args.verificationType,
          key: args.key,
        ),
      );
    },
  };
}

/// generated route for
/// [AuthScreen]
class AuthRoute extends PageRouteInfo<void> {
  const AuthRoute({List<PageRouteInfo>? children})
      : super(
          AuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CreateBookScreen]
class CreateBookRoute extends PageRouteInfo<void> {
  const CreateBookRoute({List<PageRouteInfo>? children})
      : super(
          CreateBookRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateBookRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [EbookDetailScreen]
class EbookDetailRoute extends PageRouteInfo<EbookDetailRouteArgs> {
  EbookDetailRoute({
    Key? key,
    required String id,
    String? slug,
    required EbookModel ebook,
    List<PageRouteInfo>? children,
  }) : super(
          EbookDetailRoute.name,
          args: EbookDetailRouteArgs(
            key: key,
            id: id,
            slug: slug,
            ebook: ebook,
          ),
          initialChildren: children,
        );

  static const String name = 'EbookDetailRoute';

  static const PageInfo<EbookDetailRouteArgs> page =
      PageInfo<EbookDetailRouteArgs>(name);
}

class EbookDetailRouteArgs {
  const EbookDetailRouteArgs({
    this.key,
    required this.id,
    this.slug,
    required this.ebook,
  });

  final Key? key;

  final String id;

  final String? slug;

  final EbookModel ebook;

  @override
  String toString() {
    return 'EbookDetailRouteArgs{key: $key, id: $id, slug: $slug, ebook: $ebook}';
  }
}

/// generated route for
/// [EditBookScreen]
class EditBookRoute extends PageRouteInfo<EditBookRouteArgs> {
  EditBookRoute({
    Key? key,
    required EbookModel ebookToEdit,
    List<PageRouteInfo>? children,
  }) : super(
          EditBookRoute.name,
          args: EditBookRouteArgs(
            key: key,
            ebookToEdit: ebookToEdit,
          ),
          initialChildren: children,
        );

  static const String name = 'EditBookRoute';

  static const PageInfo<EditBookRouteArgs> page =
      PageInfo<EditBookRouteArgs>(name);
}

class EditBookRouteArgs {
  const EditBookRouteArgs({
    this.key,
    required this.ebookToEdit,
  });

  final Key? key;

  final EbookModel ebookToEdit;

  @override
  String toString() {
    return 'EditBookRouteArgs{key: $key, ebookToEdit: $ebookToEdit}';
  }
}

/// generated route for
/// [ExploreScreen]
class ExploreRoute extends PageRouteInfo<void> {
  const ExploreRoute({List<PageRouteInfo>? children})
      : super(
          ExploreRoute.name,
          initialChildren: children,
        );

  static const String name = 'ExploreRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [IntroScreen]
class IntroRoute extends PageRouteInfo<void> {
  const IntroRoute({List<PageRouteInfo>? children})
      : super(
          IntroRoute.name,
          initialChildren: children,
        );

  static const String name = 'IntroRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LibraryScreen]
class LibraryRoute extends PageRouteInfo<void> {
  const LibraryRoute({List<PageRouteInfo>? children})
      : super(
          LibraryRoute.name,
          initialChildren: children,
        );

  static const String name = 'LibraryRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MeScreen]
class MeRoute extends PageRouteInfo<void> {
  const MeRoute({List<PageRouteInfo>? children})
      : super(
          MeRoute.name,
          initialChildren: children,
        );

  static const String name = 'MeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NotificationsScreen]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
      : super(
          NotificationsRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ReaderScreen]
class ReaderRoute extends PageRouteInfo<ReaderRouteArgs> {
  ReaderRoute({
    Key? key,
    required String storyId,
    required String title,
    required bool isFree,
    required int contentCount,
    required double pricePerChapter,
    required bool completed,
    List<PageRouteInfo>? children,
  }) : super(
          ReaderRoute.name,
          args: ReaderRouteArgs(
            key: key,
            storyId: storyId,
            title: title,
            isFree: isFree,
            contentCount: contentCount,
            pricePerChapter: pricePerChapter,
            completed: completed,
          ),
          initialChildren: children,
        );

  static const String name = 'ReaderRoute';

  static const PageInfo<ReaderRouteArgs> page = PageInfo<ReaderRouteArgs>(name);
}

class ReaderRouteArgs {
  const ReaderRouteArgs({
    this.key,
    required this.storyId,
    required this.title,
    required this.isFree,
    required this.contentCount,
    required this.pricePerChapter,
    required this.completed,
  });

  final Key? key;

  final String storyId;

  final String title;

  final bool isFree;

  final int contentCount;

  final double pricePerChapter;

  final bool completed;

  @override
  String toString() {
    return 'ReaderRouteArgs{key: $key, storyId: $storyId, title: $title, isFree: $isFree, contentCount: $contentCount, pricePerChapter: $pricePerChapter, completed: $completed}';
  }
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<void> {
  const ResetPasswordRoute({List<PageRouteInfo>? children})
      : super(
          ResetPasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'ResetPasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SearchScreen]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SignInScreen]
class SignInRoute extends PageRouteInfo<SignInRouteArgs> {
  SignInRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SignInRoute.name,
          args: SignInRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SignInRoute';

  static const PageInfo<SignInRouteArgs> page = PageInfo<SignInRouteArgs>(name);
}

class SignInRouteArgs {
  const SignInRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'SignInRouteArgs{key: $key}';
  }
}

/// generated route for
/// [SignUpScreen]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TabsScreen]
class TabsRoute extends PageRouteInfo<void> {
  const TabsRoute({List<PageRouteInfo>? children})
      : super(
          TabsRoute.name,
          initialChildren: children,
        );

  static const String name = 'TabsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TabsScreenSmall]
class TabsRouteSmall extends PageRouteInfo<void> {
  const TabsRouteSmall({List<PageRouteInfo>? children})
      : super(
          TabsRouteSmall.name,
          initialChildren: children,
        );

  static const String name = 'TabsRouteSmall';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [VerificationCodeScreen]
class VerificationCodeRoute extends PageRouteInfo<VerificationCodeRouteArgs> {
  VerificationCodeRoute({
    required VerificationType verificationType,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          VerificationCodeRoute.name,
          args: VerificationCodeRouteArgs(
            verificationType: verificationType,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'VerificationCodeRoute';

  static const PageInfo<VerificationCodeRouteArgs> page =
      PageInfo<VerificationCodeRouteArgs>(name);
}

class VerificationCodeRouteArgs {
  const VerificationCodeRouteArgs({
    required this.verificationType,
    this.key,
  });

  final VerificationType verificationType;

  final Key? key;

  @override
  String toString() {
    return 'VerificationCodeRouteArgs{verificationType: $verificationType, key: $key}';
  }
}
