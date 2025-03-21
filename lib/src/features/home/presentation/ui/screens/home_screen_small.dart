import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/auth/providers/user_provider.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';
import 'package:novelnooks/src/features/library/presentation/providers/ebook_detail_provider.dart';
import 'package:novelnooks/src/features/library/presentation/providers/library_provider.dart';

// Scroll controller provider
final homeScrollControllerProvider = Provider((ref) {
  final controller = ScrollController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

// Active filter provider
final activeFilterProvider = StateProvider<String>((ref) => 'For You');

// Stories state and notifier for different sections
class StoriesState {
  final List<EbookModel> stories;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;

  StoriesState({
    required this.stories,
    required this.page,
    required this.hasMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasError,
    this.errorMessage,
  });

  factory StoriesState.initial() => StoriesState(
        stories: [],
        page: 0,
        hasMore: true,
        isLoading: false,
        isLoadingMore: false,
        hasError: false,
      );

  StoriesState copyWith({
    List<EbookModel>? stories,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
  }) {
    return StoriesState(
      stories: stories ?? this.stories,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class StoriesNotifier extends StateNotifier<StoriesState> {
  final Ref ref;
  String? section;
  final Map<String, String?> additionalParams;

  StoriesNotifier(this.ref, {this.section, this.additionalParams = const {}})
      : super(StoriesState.initial()) {
    fetchStories(refresh: true);
  }

  void updateSection(String newSection) {
    section = newSection;
    fetchStories(refresh: true);
  }

  Future<void> fetchStories({
    bool refresh = false,
    bool loadMore = false,
  }) async {
    if (state.isLoadingMore || (!refresh && !state.hasMore)) return;

    final page = refresh ? 1 : state.page + 1;

    state = state.copyWith(isLoading: refresh, isLoadingMore: loadMore);

    try {
      final result = await ref.read(libraryRepositoryProvider).fetchAllEbooks(
            section: section,
            page: page,
            limit: section == 'hero' ? 5 : 10,
            searchQuery: additionalParams['searchQuery'],
            free: additionalParams['free'],
          );

      final newStories = (result['ebooks'] as List<EbookModel>);
      final pagination = result['pagination'] as PaginationModel;
      final currentPage = pagination.currentPage;
      final hasMore = pagination.hasMore;

      state = state.copyWith(
        stories: refresh ? newStories : [...state.stories, ...newStories],
        page: currentPage,
        hasMore: hasMore,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  void updateStory(EbookModel updatedStory) {
    state = state.copyWith(
      stories:
          state.stories.map((s) => s.id == updatedStory.id ? updatedStory : s).toList(),
    );
  }
}

// Providers for different sections
final heroStoriesProvider = StateNotifierProvider<StoriesNotifier, StoriesState>((ref) {
  return StoriesNotifier(ref, section: 'trending');
});

final recommendedStoriesProvider = StateNotifierProvider<StoriesNotifier, StoriesState>((ref) {
  return StoriesNotifier(ref, section: 'recommended');
});

final newReleasesProvider = StateNotifierProvider<StoriesNotifier, StoriesState>((ref) {
  return StoriesNotifier(ref, section: 'newReleases');
});

final topRatedProvider = StateNotifierProvider<StoriesNotifier, StoriesState>((ref) {
  return StoriesNotifier(ref, section: 'topRated');
});

final freeStoriesProvider = StateNotifierProvider<StoriesNotifier, StoriesState>((ref) {
  return StoriesNotifier(ref, section: 'free', additionalParams: {'free': 'true'});
});

final bestSellingProvider = StateNotifierProvider<StoriesNotifier, StoriesState>((ref) {
  return StoriesNotifier(ref, section: 'bestSelling');
});

final topCommentedProvider = StateNotifierProvider<StoriesNotifier, StoriesState>((ref) {
  return StoriesNotifier(ref, section: 'topCommented');
});

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with AutomaticKeepAliveClientMixin {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ref.read(homeScrollControllerProvider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshAllData() async {
    ref.read(heroStoriesProvider.notifier).fetchStories(refresh: true);
    await Future.wait([
      Future(() => ref.read(recommendedStoriesProvider.notifier).fetchStories(refresh: true)),
      Future(() => ref.read(newReleasesProvider.notifier).fetchStories(refresh: true)),
      Future(() => ref.read(topRatedProvider.notifier).fetchStories(refresh: true)),
      Future(() => ref.read(freeStoriesProvider.notifier).fetchStories(refresh: true)),
      Future(() => ref.read(bestSellingProvider.notifier).fetchStories(refresh: true)),
      Future(() => ref.read(topCommentedProvider.notifier).fetchStories(refresh: true)),
    ]);
  }

  @override
  bool get wantKeepAlive => true;

  String getSectionTitle(String filter) {
    switch (filter) {
      case 'For You':
        return 'Recommended For You';
      case 'Trending':
        return 'Trending Now';
      case 'New':
        return 'New Releases';
      default:
        return 'Featured $filter Books';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkBg, AppColors.neonCyan.withOpacity(0.1)]
                : [Colors.white, AppColors.brandDeepGold.withOpacity(0.2)],
            stops: const [0.0, 1.0],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshAllData,
          color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          displacement: 40.0,
          edgeOffset: 0.0,
          child: CustomScrollView(
            key: const PageStorageKey('homeScrollView'),
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: isDark ? AppColors.darkBg : Colors.white,
                elevation: 0,
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: userState.valueOrNull?.photo != null &&
                              userState.valueOrNull!.photo.isNotEmpty
                          ? NetworkImage(userState.valueOrNull!.photo)
                          : null,
                      backgroundColor: isDark
                          ? AppColors.neonCyan.withOpacity(0.2)
                          : AppColors.brandDeepGold.withOpacity(0.2),
                      child: userState.valueOrNull?.photo == null ||
                              userState.valueOrNull!.photo.isEmpty
                          ? Text(
                              userState.valueOrNull?.firstname.isNotEmpty == true
                                  ? userState.valueOrNull!.firstname[0].toUpperCase()
                                  : 'N',
                              style: TextStyle(
                                color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userState.valueOrNull != null &&
                                userState.valueOrNull!.firstname.isNotEmpty
                            ? 'Hi, ${userState.valueOrNull!.firstname}'
                            : 'Hi, Reader',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.neutralDarkGray,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                            size: 22,
                          ),
                          onPressed: () {
                            context.router.push(const SearchRoute());
                          },
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(width: 8),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.notifications_none_rounded,
                                color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                                size: 22,
                              ),
                              onPressed: () {},
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(child: _buildFilterChips(context)),
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, child) {
                    final activeFilter = ref.watch(activeFilterProvider);
                    final sectionTitle = getSectionTitle(activeFilter);
                    final heroState = ref.watch(heroStoriesProvider);

                    if (heroState.isLoading) {
                      return SizedBox(
                        height: 280,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                          ),
                        ),
                      );
                    } else if (heroState.hasError) {
                      return ErrorStateWidget(
                        errorMessage: heroState.errorMessage ?? 'An error occurred',
                        onRetry: () =>
                            ref.read(heroStoriesProvider.notifier).fetchStories(refresh: true),
                        isDark: isDark,
                        isHeroSection: true,
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                          child: Text(
                            sectionTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 280.0,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.7,
                            autoPlayInterval: const Duration(seconds: 5),
                            autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          ),
                          items: heroState.stories.map((story) {
                            return Builder(
                              builder: (BuildContext context) {
                                return FeaturedBookCard(
                                  story: story,
                                  isDark: isDark,
                                  onTap: () {
                                    ref.read(ebookDetailProvider.notifier).setCurrentEbook(story);
                                    context.router.push(
                                      EbookDetailRoute(id: story.id, ebook: story),
                                    );
                                  },
                                );
                              },
                            );
                          }).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        AppColors.neonCyan.withOpacity(0.8),
                                        AppColors.neonCyan,
                                      ]
                                    : [AppColors.brandDeepGold, AppColors.brandWarmOrange],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? AppColors.neonCyan.withOpacity(0.3)
                                      : AppColors.brandDeepGold.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  final rootRouter = AutoRouter.of(context).root;
                                  final tabsRouter =
                                      rootRouter.innerRouterOf<TabsRouter>(TabsRoute.name);
                                  if (tabsRouter != null) {
                                    tabsRouter.setActiveIndex(1);
                                  }
                                },
                                splashColor: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 24.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.black.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          MdiIcons.bookOpenPageVariant,
                                          color: isDark ? Colors.black : Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Continue Reading',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.black : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Pick up where you left off',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? Colors.black.withOpacity(0.7)
                                                    : Colors.white.withOpacity(0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: isDark ? Colors.black : Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: SectionWidget(
                  title: 'Recommended For You',
                  provider: recommendedStoriesProvider,
                ),
              ),
              SliverToBoxAdapter(
                child: SectionWidget(
                  title: 'New Releases',
                  provider: newReleasesProvider,
                ),
              ),
              SliverToBoxAdapter(
                child: SectionWidget(
                  title: 'Top Rated',
                  provider: topRatedProvider,
                ),
              ),
              SliverToBoxAdapter(
                child: SectionWidget(
                  title: 'Top Free Reads',
                  provider: freeStoriesProvider,
                ),
              ),
              SliverToBoxAdapter(
                child: SectionWidget(
                  title: 'Best Selling',
                  provider: bestSellingProvider,
                ),
              ),
              SliverToBoxAdapter(
                child: SectionWidget(
                  title: 'Top Commented Books',
                  provider: topCommentedProvider,
                ),
              ),
              SliverPadding(padding: EdgeInsets.only(bottom: bottomPadding)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.watch(activeFilterProvider);
        return SizedBox(
          height: 36,    
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(context, ref, 'For You', 'recommended'),
              _buildFilterChip(context, ref, 'Trending', 'trending'),
              _buildFilterChip(context, ref, 'New', 'newReleases'),
              _buildFilterChip(context, ref, 'Fantasy', 'genre_fantasy'),
              _buildFilterChip(context, ref, 'Romance', 'genre_romance'),
              _buildFilterChip(context, ref, 'Mystery', 'genre_mystery'),
              _buildFilterChip(context, ref, 'Sci-Fi', 'genre_scifi'),
              _buildFilterChip(context, ref, 'Historical', 'genre_historical'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    String sectionValue,
  ) {
    final activeFilter = ref.watch(activeFilterProvider);
    final isSelected = activeFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ref.read(activeFilterProvider.notifier).state = label;
        ref.read(heroStoriesProvider.notifier).updateSection(sectionValue);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0), // Reduced vertical margin
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isDark
                      ? [AppColors.neonCyan, AppColors.neonCyan.withOpacity(0.7)]
                      : [AppColors.brandDeepGold, AppColors.brandWarmOrange],
                )
              : null,
          color: isSelected ? null : (isDark ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                        .withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Reduced vertical padding
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.white70 : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final bool isDark;
  final bool isHeroSection;

  const ErrorStateWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
    required this.isDark,
    this.isHeroSection = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isHeroSection ? 280 : 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg.withOpacity(0.6) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.neonCyan.withOpacity(0.2)
              : AppColors.brandDeepGold.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Colors.red,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage.length > 100 ? '${errorMessage.substring(0, 100)}...' : errorMessage,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor:
                  isDark ? AppColors.neonCyan.withOpacity(0.5) : AppColors.brandDeepGold.withOpacity(0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, size: 18),
                const SizedBox(width: 8),
                const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionWidget extends ConsumerWidget {
  final String title;
  final StateNotifierProvider<StoriesNotifier, StoriesState> provider;

  const SectionWidget({super.key, required this.title, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 280,
          child: state.isLoading
              ? _buildSkeletonList(isDark)
              : state.hasError
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ErrorStateWidget(
                        errorMessage: state.errorMessage ?? 'Failed to load books',
                        onRetry: () => ref.read(provider.notifier).fetchStories(refresh: true),
                        isDark: isDark,
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.stories.length,
                      itemBuilder: (context, index) {
                        final story = state.stories[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: BookItem(story: story),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSkeletonList(bool isDark) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SkeletonBookItem(isDark: isDark),
        );
      },
    );
  }
}

class BookItem extends StatelessWidget {
  final EbookModel story;

  const BookItem({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayTitle = story.title.length < 20 ? story.title : '${story.title.substring(0, 15)}...';

    return GestureDetector(
      onTap: () {
        context.router.push(EbookDetailRoute(id: story.id, ebook: story));
      },
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: story.image != null && story.image!.isNotEmpty
                    ? Image.network(
                        story.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? Colors.grey[850] : Colors.grey[200],
                          child: Icon(
                            MdiIcons.bookOpenPageVariant,
                            size: 30,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                        ),
                      )
                    : Container(
                        color: isDark ? Colors.grey[850] : Colors.grey[200],
                        child: Icon(
                          MdiIcons.bookOpenPageVariant,
                          size: 30,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'By ${story.author}',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (story.averageRating > 0)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    story.averageRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            Text(
              story.free ? 'Free' : 'Paid',
              style: TextStyle(
                color: story.free ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonBookItem extends StatelessWidget {
  final bool isDark;

  const SkeletonBookItem({Key? key, required this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Colors.grey[800] : Colors.grey[300],
              ),
              child: Center(
                child: Icon(
                  MdiIcons.bookOpenPageVariant,
                  size: 24,
                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isDark ? Colors.grey[800] : Colors.grey[300],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isDark ? Colors.grey[800] : Colors.grey[300],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isDark ? Colors.grey[800] : Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedBookCard extends ConsumerWidget {
  final EbookModel story;
  final bool isDark;
  final VoidCallback onTap;

  const FeaturedBookCard({
    Key? key,
    required this.story,
    required this.isDark,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.65;
    final displayTitle = story.title.length < 20 ? story.title : '${story.title.substring(0, 20)}...';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: 280,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850]!.withOpacity(0.6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: story.image != null && story.image!.isNotEmpty
                    ? Image.network(
                        story.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.4, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'By ${story.author}',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  story.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: story.free ? Colors.green : Colors.red.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    story.free ? 'Free' : 'Paid',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(top: 12, right: 12, child: _buildLikeButton(ref)),
            Positioned(top: 12, right: 60, child: _buildBookmarkButton(ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton(WidgetRef ref) {
    final isLiked = story.isLikedByCurrentUser ?? false;

    return InkWell(
      onTap: () {
        final currentIsLiked = story.isLikedByCurrentUser ?? false;
        final updatedStory = story.copyWith(
          isLikedByCurrentUser: !currentIsLiked,
          likeCount: currentIsLiked ? story.likeCount - 1 : story.likeCount + 1,
        );
        ref.read(heroStoriesProvider.notifier).updateStory(updatedStory);
        Future(() async {
          try {
            ref.read(ebookDetailProvider.notifier).setCurrentEbook(updatedStory);
            unawaited(ref.read(ebookDetailProvider.notifier).toggleLike());
            _updateStoryInOtherProviders(ref, updatedStory);
          } catch (e) {
            print('Error updating like status: $e');
          }
        });
      },
      borderRadius: BorderRadius.circular(50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLiked ? Colors.red.withOpacity(0.2) : Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: isLiked ? Colors.red : Colors.white30, width: 1.5),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            key: ValueKey<bool>(isLiked),
            color: isLiked ? Colors.red : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(WidgetRef ref) {
    final isInReadingList = story.isInReadingList ?? false;

    return InkWell(
      onTap: () {
        final currentIsInReadingList = story.isInReadingList ?? false;
        final updatedStory = story.copyWith(isInReadingList: !currentIsInReadingList);
        ref.read(heroStoriesProvider.notifier).updateStory(updatedStory);
        Future(() async {
          try {
            ref.read(ebookDetailProvider.notifier).setCurrentEbook(updatedStory);
            unawaited(ref.read(ebookDetailProvider.notifier).toggleReadingList());
            _updateStoryInOtherProviders(ref, updatedStory);
          } catch (e) {
            print('Error updating reading list status: $e');
          }
        });
      },
      borderRadius: BorderRadius.circular(50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isInReadingList
              ? (isDark ? AppColors.neonCyan.withOpacity(0.2) : AppColors.brandDeepGold.withOpacity(0.2))
              : Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: isInReadingList
                ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                : Colors.white30,
            width: 1.5,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: Icon(
            isInReadingList ? MdiIcons.bookmark : MdiIcons.bookmarkOutline,
            key: ValueKey<bool>(isInReadingList),
            color: isInReadingList
                ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: isDark ? Colors.grey[850] : Colors.grey[200],
      child: Center(
        child: Icon(
          MdiIcons.bookOpenPageVariant,
          size: 48,
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
    );
  }

  void _updateStoryInOtherProviders(WidgetRef ref, EbookModel updatedStory) {
    final providers = [
      recommendedStoriesProvider,
      newReleasesProvider,
      topRatedProvider,
      freeStoriesProvider,
      bestSellingProvider,
      topCommentedProvider,
    ];
    for (final provider in providers) {
      try {
        final state = ref.read(provider);
        final index = state.stories.indexWhere((s) => s.id == updatedStory.id);
        if (index >= 0) {
          ref.read(provider.notifier).updateStory(updatedStory);
        }
      } catch (e) {}
    }
  }
}

class FeatureSkeletonItem extends StatelessWidget {
  final bool isDark;

  const FeatureSkeletonItem({Key? key, required this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.65;

    return Container(
      width: cardWidth,
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]!.withOpacity(0.6) : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.bookOpenPageVariant,
                    size: 48,
                    color: isDark ? Colors.grey[700] : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isDark ? Colors.grey[700] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isDark ? Colors.grey[700] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}