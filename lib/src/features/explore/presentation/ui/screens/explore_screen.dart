import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/common/widgets/app_error.dart';
import 'package:novelnooks/src/common/widgets/book_grid_item.dart';
import 'package:novelnooks/src/common/widgets/loading_states.dart';
import 'package:novelnooks/src/features/explore/presentation/providers/explore_provider.dart';
import 'package:novelnooks/src/features/explore/presentation/ui/search/book_search_delegate.dart';

@RoutePage()
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedTag = "Romance"; // Default selected tag
  
  // List of available tags
  final List<String> _availableTags = [
    "Romance",
    "Werewolf",
    "Mafia",
    "System",
    "Fantasy",
    "Urban",
    "YA/TEEN",
    "Paranormal",
    "Mystery/Thriller",
    "Eastern",
    "Games",
    "History",
    "MM Romance",
    "Sci-Fi",
    "War",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    
    // Load initial data with default tag
    Future.microtask(() {
      ref.read(exploreProvider.notifier).fetchBooksByTag(_selectedTag);
    });
    
    // Set up pagination
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(exploreProvider.notifier).loadMoreBooks();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectTag(String tag) {
    if (_selectedTag != tag) {
      setState(() {
        _selectedTag = tag;
      });
      ref.read(exploreProvider.notifier).fetchBooksByTag(tag);
      
      // Scroll back to top when changing tags
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  // ignore: unused_element
  void _openSearch() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showSearch(
      context: context,
      delegate: BookSearchDelegate(
        ref: ref,
        isDark: isDark,
        initialTag: _selectedTag, // Pass the current tag to search within it
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildTagFilters(isDark),
            
            Expanded(
              child: _buildBooksList(state, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark 
            ? [Colors.black.withOpacity(0.6), AppColors.darkBg.withOpacity(0.0)] 
            : [AppColors.brandDeepGold.withOpacity(0.05), Colors.white.withOpacity(0.0)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                size: 28,
                color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
              ),
              const SizedBox(width: 12),
              Text(
                'Explore',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              
             ],
          ),
          const SizedBox(height: 8),
          Text(
            'Discover books by genre that match your taste',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagFilters(bool isDark) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _availableTags.length,
        itemBuilder: (context, index) {
          final tag = _availableTags[index];
          final isSelected = _selectedTag == tag;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(tag),
              onSelected: (_) => _selectTag(tag),
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              selectedColor: isDark ? AppColors.neonCyan.withOpacity(0.2) : AppColors.brandDeepGold.withOpacity(0.2),
              checkmarkColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
              labelStyle: TextStyle(
                color: isSelected 
                    ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              elevation: isSelected ? 2 : 0,
              shadowColor: isSelected 
                  ? (isDark ? AppColors.neonCyan.withOpacity(0.3) : AppColors.brandDeepGold.withOpacity(0.3))
                  : Colors.transparent,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBooksList(ExploreState state, bool isDark) {
    // Always show loading state when isLoading is true and books are empty
    if (state.isLoading && state.books.isEmpty) {
      return _buildLoadingState(isDark);
    }
    
    if (state.error != null && state.books.isEmpty) {
      return AppError(
        message: state.error!,
        onRetry: () => ref.read(exploreProvider.notifier).fetchBooksByTag(_selectedTag),
      );
    }
    
    if (!state.isLoading && state.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 64,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'No books found for this tag',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => ref.read(exploreProvider.notifier).fetchBooksByTag(_selectedTag),
              icon: Icon(
                Icons.refresh_rounded,
                color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
              ),
              label: Text(
                'Try Again',
                style: TextStyle(
                  color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(exploreProvider.notifier).fetchBooksByTag(_selectedTag);
      },
      color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.hasMore ? state.books.length + 1 : state.books.length,
        itemBuilder: (context, index) {
          if (index >= state.books.length) {
            return const Center(
              child: LoadingBookCard(),
            );
          }
          
          final book = state.books[index];
          return BookGridItem(book: book);
        },
      ),
    );
  }

  // Add a new method to create a beautiful loading state with shimmer effect
  Widget _buildLoadingState(bool isDark) {
    return Column(
      children: [
        // Create a shimmer effect for the loading state
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return const LoadingBookCard();
            },
          ),
        ),
      ],
    );
  }
}