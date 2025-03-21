import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/features/reader/services/reader_service.dart';
import 'package:equatable/equatable.dart';

class Chapter {
  final String title;
  final String content;
  final int index;
  
  Chapter({
    required this.title,
    required this.content,
    required this.index,
  });
}

class ReaderState extends Equatable {
  final String storyId;
  final String title;
  final List<Chapter> chapters;
  final int currentChapterIndex;
  final bool isLoading;
  final String? errorMessage;
  final bool isPremiumContent;
  final bool previewMode;
  final bool completed;
  final double downloadProgress;
  final String? epubFilePath;
  
  const ReaderState({
    this.storyId = '',
    this.title = '',
    this.chapters = const [],
    this.currentChapterIndex = 0,
    this.isLoading = false,
    this.errorMessage,
    this.isPremiumContent = false,
    this.previewMode = false,
    this.completed = false,
    this.downloadProgress = 0.0,
    this.epubFilePath,
  });
  
  ReaderState copyWith({
    String? storyId,
    String? title,
    List<Chapter>? chapters,
    int? currentChapterIndex,
    bool? isLoading,
    String? errorMessage,
    bool? isPremiumContent,
    bool? previewMode,
    bool? completed,
    double? downloadProgress,
    String? epubFilePath,
  }) {
    return ReaderState(
      storyId: storyId ?? this.storyId,
      title: title ?? this.title,
      chapters: chapters ?? this.chapters,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isPremiumContent: isPremiumContent ?? this.isPremiumContent,
      previewMode: previewMode ?? this.previewMode,
      completed: completed ?? this.completed,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      epubFilePath: epubFilePath ?? this.epubFilePath,
    );
  }
  
  @override
  List<Object?> get props => [
    storyId,
    title,
    chapters,
    currentChapterIndex,
    isLoading,
    errorMessage,
    isPremiumContent,
    previewMode,
    completed,
    downloadProgress,
    epubFilePath,
  ];
}

class ReaderNotifier extends StateNotifier<ReaderState> {
  final ReaderService _readerService;
  // ignore: unused_field
  final Ref _ref;
  
  ReaderNotifier(this._readerService, this._ref) : super(const ReaderState());
  
  // Navigate to specific chapter
  void navigateToChapter(int index) {
    if (index >= 0 && index < state.chapters.length) {
      state = state.copyWith(currentChapterIndex: index);
    }
  }
  
  // Navigate to next chapter
  void nextChapter() {
    if (state.currentChapterIndex < state.chapters.length - 1) {
      state = state.copyWith(currentChapterIndex: state.currentChapterIndex + 1);
    }
  }
  
  // Navigate to previous chapter
  void previousChapter() {
    if (state.currentChapterIndex > 0) {
      state = state.copyWith(currentChapterIndex: state.currentChapterIndex - 1);
    }
  }

  Future<void> loadEpub(
    String storyId,
    String title,
    bool isFree,
    int contentCount,
    double pricePerChapter,
    bool completed,
  ) async {
    state = state.copyWith(
      storyId: storyId,
      title: title,
      isLoading: true,
      errorMessage: null,
      completed: completed,
      downloadProgress: 0.0,
      epubFilePath: null,
    );
    
    try {
      // Check if user can read the full story
      final canReadFull = await _readerService.canReadFullStory(
        storyId, isFree, contentCount, pricePerChapter
      );
      
      // If user can't read full story and story isn't free, show preview mode
      if (!canReadFull && !isFree) {
        state = state.copyWith(
          previewMode: true,
        );
      }
      
      // Check for cached EPUB file
      final cachedPath = await _readerService.getCachedEpubPath(storyId);
      
      if (cachedPath != null) {
        state = state.copyWith(
          epubFilePath: cachedPath,
          isLoading: false,
          downloadProgress: 1.0,
        );
      } else {
        // Download EPUB file
        state = state.copyWith(downloadProgress: 0.05);
        
        final filePath = await _readerService.downloadEpubFile(
          storyId,
          title,
          completed,
          (progress) {
            if (!state.isLoading) return;
            state = state.copyWith(downloadProgress: 0.05 + (progress * 0.9));
          },
        );
        
        state = state.copyWith(
          epubFilePath: filePath,
          isLoading: false,
          downloadProgress: 1.0,
        );
      }
      

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        downloadProgress: 0.0,
      );
    }
  }
}

final readerProvider = StateNotifierProvider.autoDispose<ReaderNotifier, ReaderState>((ref) {
  final readerService = ref.watch(readerServiceProvider);
  return ReaderNotifier(readerService, ref);
});