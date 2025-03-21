import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/features.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';
import 'package:novelnooks/src/features/library/data/repositories/library_repository.dart';
import 'package:novelnooks/src/features/library/presentation/providers/library_provider.dart';

// Search suggestion model
class SearchSuggestion {
  final String id;
  final String title;
  final String? slug;
  final String? summary;
  final String? image;
  final String matchType;
  final String author;
  final String authorId;
  final List<String> tags;

  SearchSuggestion({
    required this.id,
    required this.title,
    this.slug,
    this.summary,
    this.image,
    required this.matchType,
    required this.author,
    required this.authorId,
    required this.tags,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      id: json['_id'],
      title: json['title'],
      slug: json['slug'],
      summary: json['summary'],
      image: json['image'],
      matchType: json['matchType'],
      author: json['author'],
      authorId: json['authorId'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

// Search state
class SearchState {
  final List<SearchSuggestion> suggestions;
  final List<EbookModel> results;
  final bool isLoadingSuggestions;
  final bool isLoadingResults;
  final bool isLoadingMoreResults;
  final String? errorMessage;
  final int currentPage;
  final bool hasMoreResults;

  const SearchState({
    this.suggestions = const [],
    this.results = const [],
    this.isLoadingSuggestions = false,
    this.isLoadingResults = false,
    this.isLoadingMoreResults = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMoreResults = true,
  });

  SearchState copyWith({
    List<SearchSuggestion>? suggestions,
    List<EbookModel>? results,
    bool? isLoadingSuggestions,
    bool? isLoadingResults,
    bool? isLoadingMoreResults,
    String? errorMessage,
    int? currentPage,
    bool? hasMoreResults,
  }) {
    return SearchState(
      suggestions: suggestions ?? this.suggestions,
      results: results ?? this.results,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      isLoadingResults: isLoadingResults ?? this.isLoadingResults,
      isLoadingMoreResults: isLoadingMoreResults ?? this.isLoadingMoreResults,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMoreResults: hasMoreResults ?? this.hasMoreResults,
    );
  }
}

// Search notifier
class SearchNotifier extends StateNotifier<SearchState> {
  final LibraryRepository _repository;
  Timer? _debounceTimer;
  
  SearchNotifier(this._repository) : super(const SearchState());
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  Future<void> getSuggestions(String query) async {
    if (query.length < 2) {
      state = state.copyWith(suggestions: [], isLoadingSuggestions: false);
      return;
    }
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      state = state.copyWith(isLoadingSuggestions: true);
      
      try {
        final result = await _repository.getSearchSuggestions(query);
        final suggestions = (result['suggestions'] as List)
            .map((item) => SearchSuggestion.fromJson(item))
            .toList();
        
        state = state.copyWith(
          suggestions: suggestions,
          isLoadingSuggestions: false,
        );
      } catch (e) {
        state = state.copyWith(
          suggestions: [],
          isLoadingSuggestions: false,
          errorMessage: e.toString(),
        );
      }
    });
  }
  
  Future<void> search(String query, {bool refresh = false}) async {
    if (query.length < 2) return;
    
    if (refresh) {
      state = state.copyWith(
        isLoadingResults: true, 
        currentPage: 1,
        hasMoreResults: true,
      );
    } else {
      if (!state.hasMoreResults || state.isLoadingMoreResults) return;
      state = state.copyWith(isLoadingMoreResults: true);
    }
    
    try {
      final result = await _repository.searchEbooks(
        query: query,
        page: refresh ? 1 : state.currentPage + 1,
      );
      
      final newResults = result['ebooks'] as List<EbookModel>;
      final pagination = result['pagination'] as PaginationModel;
      
      state = state.copyWith(
        results: refresh ? newResults : [...state.results, ...newResults],
        isLoadingResults: false,
        isLoadingMoreResults: false,
        currentPage: pagination.currentPage,
        hasMoreResults: pagination.hasMore,
        suggestions: [], // Clear suggestions when showing results
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingResults: false,
        isLoadingMoreResults: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  void clearSuggestions() {
    state = state.copyWith(suggestions: []);
  }
  
  void clearResults() {
    state = state.copyWith(
      results: [],
      currentPage: 1,
      hasMoreResults: true,
    );
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(libraryRepositoryProvider));
});

@RoutePage()
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSuggestions = false;
  String _lastSearchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    if (query.length >= 2) {
      setState(() {
        _showSuggestions = true;
      });
      ref.read(searchProvider.notifier).getSuggestions(query);
    } else {
      setState(() {
        _showSuggestions = false;
      });
      ref.read(searchProvider.notifier).clearSuggestions();
    }
  }
  
  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (maxScroll - currentScroll <= 500) {
      // Load more results when near bottom
      ref.read(searchProvider.notifier).search(_lastSearchQuery);
    }
  }
  
  void _executeSearch(String query) {
    if (query.length < 2) return;
    
    setState(() {
      _showSuggestions = false;
      _lastSearchQuery = query;
    });
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    ref.read(searchProvider.notifier).search(query, refresh: true);
  }
  
  void _onSuggestionTapped(SearchSuggestion suggestion) {
    _searchController.text = suggestion.title;
    _executeSearch(suggestion.title);
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(searchProvider);
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : Colors.white,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for books, authors, or genres',
            hintStyle: TextStyle(
              color: isDark ? Colors.white60 : Colors.black45,
            ),
            border: InputBorder.none,
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
          onSubmitted: _executeSearch,
        ),
        actions: _searchController.text.isNotEmpty
            ? [
                IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchProvider.notifier).clearResults();
                      ref.read(searchProvider.notifier).clearSuggestions();
                    },
                  )
              ]
            : [],
      ),
      body: Stack(
        children: [
          if (!_showSuggestions && state.results.isEmpty && !state.isLoadingResults)
            _buildEmptyState(isDark),
          if (!_showSuggestions && (state.results.isNotEmpty || state.isLoadingResults))
            _buildSearchResults(isDark, state),
          if (_showSuggestions)
            _buildSuggestions(isDark, state),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'Search for your next great read',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestions(bool isDark, SearchState state) {
    return AnimatedOpacity(
      opacity: _showSuggestions ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        color: isDark ? AppColors.darkBg : Colors.white,
        child: state.isLoadingSuggestions
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: state.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = state.suggestions[index];
                  return ListTile(
                    leading: suggestion.image != null && suggestion.image!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              suggestion.image!,
                              width: 40,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 40,
                                height: 60,
                                color: isDark ? Colors.grey[800] : Colors.grey[200],
                                child: Icon(
                                  MdiIcons.bookOpenPageVariant,
                                  size: 20,
                                  color: isDark ? Colors.white24 : Colors.black12,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 60,
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Icon(
                              MdiIcons.bookOpenPageVariant,
                              size: 20,
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                          ),
                    title: Text(
                      suggestion.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: suggestion.matchType == 'summary' && suggestion.summary != null
                        ? Text(
                            suggestion.summary!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                            ),
                          )
                        : Text(
                            'By ${suggestion.author}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                    onTap: () => _onSuggestionTapped(suggestion),
                  );
                },
              ),
      ),
    );
  }
  
  Widget _buildSearchResults(bool isDark, SearchState state) {
    if (state.isLoadingResults && state.results.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Results for "${_lastSearchQuery}"',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.50,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.results.length + (state.isLoadingMoreResults ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.results.length) {
                // Show loading indicator at the end
                return Center(
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                  ),
                );
              }
              
              final book = state.results[index];
              return BookItem(story: book);
            },
          ),
        ),
      ],
    );
  }
}