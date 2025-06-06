import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';

class ExploreState {
  final List<EbookModel> books;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final String currentTag;

  const ExploreState({
    this.books = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.currentTag = 'Romance',
  });

  ExploreState copyWith({
    List<EbookModel>? books,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    String? currentTag,
  }) {
    return ExploreState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      currentTag: currentTag ?? this.currentTag,
    );
  }
}

class ExploreNotifier extends StateNotifier<ExploreState> {
  ExploreNotifier() : super(const ExploreState(isLoading: true)); // Start with loading state
  
  Future<void> fetchBooksByTag(String tag) async {
    // Always show loading when fetching new tag
    state = state.copyWith(
      isLoading: true,
      error: null,
      books: [], 
      currentPage: 1,
      currentTag: tag,
      hasMore: true,
    );
    
    try {
      final response = await DioConfig.dio!.get(
        '/ebook/tag/$tag', 
        queryParameters: {'page': 1, 'limit': 10},
      );
      
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> booksJson = response.data['data'];
        final books = booksJson.map((json) => EbookModel.fromJson(json)).toList();
        
        final totalPages = response.data['pages'] ?? 1;
        
        state = state.copyWith(
          books: books,
          isLoading: false,
          hasMore: state.currentPage < totalPages,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'Failed to load books',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong'
      );
    }
  }
  
  Future<void> loadMoreBooks() async {
    if (state.isLoading || !state.hasMore) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final nextPage = state.currentPage + 1;
      
      final response = await DioConfig.dio!.get(
        '/ebook/tag/${state.currentTag}',
        queryParameters: {'page': nextPage, 'limit': 10},
      );
      
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> booksJson = response.data['data'];
        final newBooks = booksJson.map((json) => EbookModel.fromJson(json)).toList();
        
        final totalPages = response.data['pages'] ?? 1;
        
        state = state.copyWith(
          books: [...state.books, ...newBooks],
          isLoading: false,
          currentPage: nextPage,
          hasMore: nextPage < totalPages,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'Failed to load more books',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong'
        );
    }
  }
}

final exploreProvider = StateNotifierProvider<ExploreNotifier, ExploreState>((ref) {
  return ExploreNotifier();
});