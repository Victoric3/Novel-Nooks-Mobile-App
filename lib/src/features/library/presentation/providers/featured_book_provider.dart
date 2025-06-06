import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';

class FeaturedBookState {
  final EbookModel? featuredBook;
  final bool isLoading;
  final String? errorMessage;

  FeaturedBookState({
    this.featuredBook,
    this.isLoading = false,
    this.errorMessage,
  });

  FeaturedBookState copyWith({
    EbookModel? featuredBook,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FeaturedBookState(
      featuredBook: featuredBook ?? this.featuredBook,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FeaturedBookNotifier extends StateNotifier<FeaturedBookState> {
  FeaturedBookNotifier() : super(FeaturedBookState());

  Future<bool> toggleFeaturedStatus(String ebookId, bool makeFeature) async {
    try {
      final endpoint = makeFeature ? '/admin/featured' : '/admin/featured';
      final method = makeFeature ? 'POST' : 'DELETE';
      
      final response = method == 'POST'
          ? await DioConfig.dio!.post(endpoint, data: {'ebookId': ebookId})
          : await DioConfig.dio!.delete(endpoint, data: {'ebookId': ebookId});

      if (response.statusCode == 200) {
        print('Featured status updated successfully: $makeFeature');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchRandomFeaturedBook() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final response = await DioConfig.dio!.get('/admin/random-featured');
      
      if (response.statusCode == 200 && response.data['success']) {
        final bookData = response.data['data'];
        final featuredBook = EbookModel.fromJson(bookData);
        
        state = state.copyWith(
          featuredBook: featuredBook,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.data['message'] ?? 'Failed to fetch featured book',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearFeaturedBook() {
    state = FeaturedBookState();
  }
}

final featuredBookProvider = StateNotifierProvider<FeaturedBookNotifier, FeaturedBookState>((ref) {
  return FeaturedBookNotifier();
});