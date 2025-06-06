import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';
import 'package:novelnooks/src/features/create/data/models/create_book_model.dart';
import 'package:novelnooks/src/features/create/data/repositories/create_book_repository.dart';

// Available genre options
final genreOptions = [
  "Romance", "Werewolf", "Mafia", "System", "Fantasy", "Urban", "YA/TEEN",
  "Paranormal", "Mystery/Thriller", "Eastern", "Games", "History",
  "MM Romance", "Sci-Fi", "War", "Other"
];

// Style labels
final styleLabels = [
  "Action", "Adventurous", "Comedy", "Contemporary", "Dark Romance", "Drama", 
  "Eastern", "Fast-Paced Plot", "First-Person POV", "Girl Power", "Mystery", 
  "Steamy", "Sweet Love", "Third-Person POV", "Tragedy", "Werewolf", "Xianxia", 
  "Familial Bond", "Nothing"
];

// Character labels
final characterLabels = [
  "Actor/Actresses", "Agent", "Alpha", "Angel", "Arrogant", "Artist", "Bad Boy", 
  "Bad Girl", "Beast", "Beta", "Bully", "CEO", "Demon", "Detective", "Doctor", 
  "Dominant", "Dragon", "Gamer", "Genius Baby", "Golden Boy", "Good Girl", 
  "Heir/Heiress", "Hero/Heroine", "Hidden Identity", "Hunter", "Hybrid", "Luna", 
  "Lycan", "Mafia", "Medical Genius", "Nanny", "Omega", "Playboy", "Police", 
  "Professor", "Rebel", "Rogue", "Ruthless", "Secretary", "Slave", "Star", 
  "Teenager", "Triplets", "Twins", "Vampire", "Warrior", "Witch/Wizard", 
  "Possessive", "Protective", "Optimistic", "Victim", "Paranoid"
];

// Setting labels
final settingLabels = [
  "Affair", "Age Group", "Alternate Universe", "Apocalypse", "Betrayal", 
  "Blind Date", "Campus", "Contract Marriage", "Cultivation", "Divorce", 
  "Face-Slapping", "First Love", "Flash Marriage", "Forbidden Love", 
  "Forgiveness", "Gay for You", "God of War", "Golden Finger", "Harem", 
  "Hate to Love", "Immortal Hero", "Incredible Son-in-Law", "Instant Billionaire", 
  "Kingdom-Building", "Level Up", "Lit RPG", "Love After Marriage", 
  "Love at First Sight", "Love Triangle", "Lovers Reunion", "Misunderstanding", 
  "MxM", "Office Relationship", "Pregnant", "Reborn", "Regret", "Reject", 
  "Revenge", "Reverse Harem", "Royal", "Runaway Bride/Groom", "Runaway with a Baby", 
  "Second Chance", "Secret Love", "Sports", "Substitute Bride", "Superpower", 
  "Twist", "Twisted", "Weak to Strong"
];

// State class
class CreateBookState {
  final int currentStep;
  final CreateBookModel book;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool isSuccess;
  final double uploadProgress; 
  
  CreateBookState({
    required this.currentStep,
    required this.book,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.isSuccess,
    this.uploadProgress = 0.0,
  });
  
  factory CreateBookState.initial() => CreateBookState(
    currentStep: 0,
    book: CreateBookModel(),
    isLoading: false,
    hasError: false,
    isSuccess: false,
    uploadProgress: 0.0, // Add this explicitly
  );
  
  CreateBookState copyWith({
    int? currentStep,
    CreateBookModel? book,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? isSuccess,
    double? uploadProgress,
  }) {
    return CreateBookState(
      currentStep: currentStep ?? this.currentStep,
      book: book ?? this.book,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

// Provider
class CreateBookNotifier extends StateNotifier<CreateBookState> {
  final CreateBookRepository repository;
  
  CreateBookNotifier(this.repository) : super(CreateBookState.initial());
  
  void setCurrentStep(int step) {
    state = state.copyWith(currentStep: step);
  }
  
  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }
  
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }
  
  void setCoverImage(File image) {
    final updatedBook = state.book.copyWith(coverImage: image);
    state = state.copyWith(book: updatedBook);
  }
  
  void setTitle(String title) {
    final updatedBook = state.book.copyWith(title: title);
    state = state.copyWith(book: updatedBook);
  }
  
  void setTargetAudience(String audience) {
    final updatedBook = state.book.copyWith(targetAudience: audience);
    state = state.copyWith(book: updatedBook);
  }
  
  void toggleGenre(String genre) {
    final currentGenres = List<String>.from(state.book.genres);
    if (currentGenres.contains(genre)) {
      currentGenres.remove(genre);
    } else {
      currentGenres.add(genre);
    }
    
    final updatedBook = state.book.copyWith(genres: currentGenres);
    state = state.copyWith(book: updatedBook);
  }
  
  void toggleStyleLabel(String label) {
    final currentLabels = List<String>.from(state.book.styleLabels);
    if (currentLabels.contains(label)) {
      currentLabels.remove(label);
    } else {
      currentLabels.add(label);
    }
    
    final updatedBook = state.book.copyWith(styleLabels: currentLabels);
    state = state.copyWith(book: updatedBook);
  }
  
  void toggleCharacterLabel(String label) {
    final currentLabels = List<String>.from(state.book.characterLabels);
    if (currentLabels.contains(label)) {
      currentLabels.remove(label);
    } else {
      currentLabels.add(label);
    }
    
    final updatedBook = state.book.copyWith(characterLabels: currentLabels);
    state = state.copyWith(book: updatedBook);
  }
  
  void toggleSettingLabel(String label) {
    final currentLabels = List<String>.from(state.book.settingLabels);
    if (currentLabels.contains(label)) {
      currentLabels.remove(label);
    } else {
      currentLabels.add(label);
    }
    
    final updatedBook = state.book.copyWith(settingLabels: currentLabels);
    state = state.copyWith(book: updatedBook);
  }
  
  void setSummary(String summary) {
    final updatedBook = state.book.copyWith(summary: summary);
    state = state.copyWith(book: updatedBook);
  }
  
  void setIsCompleted(bool isCompleted) {
    final updatedBook = state.book.copyWith(isCompleted: isCompleted);
    state = state.copyWith(book: updatedBook);
  }
  
  void setIsFree(bool isFree) {
    final updatedBook = state.book.copyWith(isFree: isFree);
    state = state.copyWith(book: updatedBook);
  }
  
  void setPdfFile(File file) {
    final updatedBook = state.book.copyWith(pdfFile: file);
    state = state.copyWith(book: updatedBook);
  }
  
  void setPdfBytes(Uint8List bytes) {
    final updatedBook = state.book.copyWith(pdfBytes: bytes);
    state = state.copyWith(book: updatedBook);
  }
  
  // Initialize with existing book data for editing
  void initializeForEditing(CreateBookModel bookModel) {
    state = CreateBookState(
      currentStep: 0,
      book: bookModel,
      isLoading: false,
      hasError: false,
      errorMessage: null,
      isSuccess: false,
    );
  }
  
  // For PDF removal in edit mode
  void clearPdf() {
    state = state.copyWith(
      book: state.book.copyWith(
        pdfFile: null,
        pdfBytes: null,
      ),
    );
  }
  
  Future<void> submitBook() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, hasError: false, errorMessage: null, uploadProgress: 0.0);
    
    try {
      final formData = FormData();
      
      // Add book data
      formData.fields.add(MapEntry('title', state.book.title));
      formData.fields.add(MapEntry('summary', state.book.summary));
      formData.fields.add(MapEntry('tags', jsonEncode(state.book.genres)));
      
      final allLabels = [
        ...state.book.styleLabels, 
        ...state.book.characterLabels, 
        ...state.book.settingLabels
      ];
      formData.fields.add(MapEntry('labels', jsonEncode(allLabels)));
      
      formData.fields.add(MapEntry('completed', state.book.isCompleted.toString()));
      formData.fields.add(MapEntry('free', state.book.isFree.toString()));
      
      // Add cover image
      if (state.book.coverImage != null) {
        final bytes = await state.book.coverImage!.readAsBytes();
        formData.files.add(MapEntry(
          'image',
          MultipartFile.fromBytes(
            bytes,
            filename: 'cover_image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        ));
      }
      
      // Add PDF file
      if (state.book.pdfFile != null) {
        final bytes = await state.book.pdfFile!.readAsBytes();
        formData.files.add(MapEntry(
          'pdfFile',
          MultipartFile.fromBytes(
            bytes,
            filename: 'book_content.pdf',
            contentType: MediaType('application', 'pdf'),
          ),
        ));
      } else if (state.book.pdfBytes != null) {
        formData.files.add(MapEntry(
          'pdfFile',
          MultipartFile.fromBytes(
            state.book.pdfBytes!,
            filename: 'book_content.pdf',
            contentType: MediaType('application', 'pdf'),
          ),
        ));
      }
      
      // Send request with upload progress tracking
      final response = await DioConfig.dio!.post(
        '/ebook',
        data: formData,
        onSendProgress: (sent, total) {
          if (total != -1) {
            final progress = sent / total;
            state = state.copyWith(uploadProgress: progress);
          }
        },
      );
      
      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          uploadProgress: 1.0,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: 'Failed to create book. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }
  
  // Add method to update an existing book
  Future<void> updateBook() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, hasError: false, errorMessage: null, uploadProgress: 0.0);
    
    try {
      final formData = FormData();
      
      // Add the book ID for update
      formData.fields.add(MapEntry('ebookId', state.book.ebookId!));
      
      // Add basic book data
      formData.fields.add(MapEntry('title', state.book.title));
      formData.fields.add(MapEntry('summary', state.book.summary));
      
      // Add tags and labels
      formData.fields.add(MapEntry('tags', jsonEncode(state.book.genres)));
      
      final allLabels = [
        ...state.book.styleLabels, 
        ...state.book.characterLabels, 
        ...state.book.settingLabels
      ];
      formData.fields.add(MapEntry('labels', jsonEncode(allLabels)));
      
      // Set completed status
      formData.fields.add(MapEntry('completed', state.book.isCompleted.toString()));
      formData.fields.add(MapEntry('free', state.book.isFree.toString()));
      
      // Add cover image if changed
      if (state.book.coverImage != null) {
        final bytes = await state.book.coverImage!.readAsBytes();
        formData.files.add(MapEntry(
          'image',
          MultipartFile.fromBytes(
            bytes,
            filename: 'cover_image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        ));
      }
      
      // Add PDF file if changed
      if (state.book.pdfFile != null) {
        final bytes = await state.book.pdfFile!.readAsBytes();
        formData.files.add(MapEntry(
          'pdfFile',
          MultipartFile.fromBytes(
            bytes,
            filename: 'book_content.pdf',
            contentType: MediaType('application', 'pdf'),
          ),
        ));
      } else if (state.book.pdfBytes != null) {
        formData.files.add(MapEntry(
          'pdfFile',
          MultipartFile.fromBytes(
            state.book.pdfBytes!,
            filename: 'book_content.pdf',
            contentType: MediaType('application', 'pdf'),
          ),
        ));
      }
      
      // Send request with upload progress tracking
      final response = await DioConfig.dio!.put(
        '/ebook/edit',
        data: formData,
        onSendProgress: (sent, total) {
          if (total != -1) {
            final progress = sent / total;
            state = state.copyWith(uploadProgress: progress);
          }
        },
      );
      
      // Check if response is successful (status code 200-299)
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true, // Set success flag
          hasError: false, // Ensure error flag is false
          errorMessage: null, // Clear any error messages
          uploadProgress: 1.0,
        );
      } else {
        // This should not happen with dio (it throws on non-2xx),
        // but handling just in case
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: 'Failed to update book. Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }
  
  void resetState() {
    state = CreateBookState.initial();
  }
  
  void clearError() {
    // Only clear the error state without affecting other state properties
    state = state.copyWith(
      hasError: false,
      errorMessage: null,
    );
  }

  void clearSuccess() {
    // Only clear the success state without affecting other state properties
    state = state.copyWith(
      isSuccess: false,
    );
  }
}

// Create book provider
final createBookProvider = StateNotifierProvider<CreateBookNotifier, CreateBookState>((ref) {
  final repository = ref.watch(createBookRepositoryProvider);
  return CreateBookNotifier(repository);
});