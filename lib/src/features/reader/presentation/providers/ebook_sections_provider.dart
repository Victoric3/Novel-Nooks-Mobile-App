import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';
import 'package:novelnooks/src/features/reader/data/repositories/ebook_sections_repository.dart';

/// Repository provider
final ebookSectionsRepositoryProvider = Provider<EbookSectionsRepository>((ref) {
  return EbookSectionsRepository(ref);
});

/// State for tracking sections download progress
class SectionsDownloadState {
  final bool isLoading;
  final double progress;
  final int downloadedBytes;
  final int totalBytes; // Add this field
  final String? errorMessage;
  final EbookModel? ebook;
  final bool isCached;

  SectionsDownloadState({
    this.isLoading = false,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0, // Initialize
    this.errorMessage,
    this.ebook,
    this.isCached = false,
  });

  SectionsDownloadState copyWith({
    bool? isLoading,
    double? progress, 
    int? downloadedBytes,
    int? totalBytes, // Add to copyWith
    String? errorMessage,
    EbookModel? ebook,
    bool? isCached,
  }) {
    return SectionsDownloadState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes, // Add to the constructor call
      errorMessage: errorMessage,
      ebook: ebook ?? this.ebook,
      isCached: isCached ?? this.isCached,
    );
  }
}

/// Notifier for sections download state
class SectionsNotifier extends StateNotifier<SectionsDownloadState> {
  final EbookSectionsRepository _repository;
  final String ebookId;
  
  SectionsNotifier(this._repository, this.ebookId) : super(SectionsDownloadState()) {
    _initialize();
  }
  
  /// Initialize by checking for cached content
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Check if sections exist in cache
      final hasCached = await _repository.hasCachedSections(ebookId);
      
      if (hasCached) {
        // Load cached content immediately
        final cachedEbook = await _repository.loadSectionsFromLocalStorage(ebookId);
        if (cachedEbook != null && cachedEbook.sections != null && cachedEbook.sections!.isNotEmpty) {
          state = state.copyWith(
            ebook: cachedEbook,
            isLoading: false,
            isCached: true,
          );
          
          // Check if an update is needed in background
          _checkForUpdates();
          return;
        }
      }
      
      // No cache - need to fetch sections
      await fetchSections();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Check if cached sections need updating
  Future<void> _checkForUpdates() async {
    try {
      final status = await _repository.checkSectionsStatus(ebookId);
      
      if (status.needsUpdate) {
        // Show a loading state with the current content still available
        state = state.copyWith(
          isLoading: true,
          errorMessage: null,
        );
        
        // Fetch updated sections
        await fetchSections();
      }
    } catch (e) {
      // Silent failure - we still have cached content
      print('Error checking for updates: $e');
    }
  }
  
  /// Fetch sections from server
  Future<void> fetchSections() async {
    if (state.isLoading) return;
    
    // Start with loading state but preserve existing data for UI continuity
    state = state.copyWith(
      isLoading: true,
      progress: 0.0,
      downloadedBytes: 0,
      errorMessage: null,
    );
    
    try {
      final ebook = await _repository.fetchSections(
        ebookId,
        onProgress: (progress, bytes, total) {
          state = state.copyWith(
            progress: progress,
            downloadedBytes: bytes,
            totalBytes: total,
          );
        },
      );
      
      // Important: Create a completely new state instead of using copyWith
      // This ensures we don't carry over any data from the previous state
      state = SectionsDownloadState(
        ebook: ebook,
        isLoading: false,
        progress: 1.0,
        downloadedBytes: 0,
        isCached: false, // Mark as freshly loaded, not cached
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

/// Provider for sections with download progress
final sectionsProvider = StateNotifierProvider.family<SectionsNotifier, SectionsDownloadState, String>(
  (ref, ebookId) {
    final repository = ref.watch(ebookSectionsRepositoryProvider);
    return SectionsNotifier(repository, ebookId);
  },
);