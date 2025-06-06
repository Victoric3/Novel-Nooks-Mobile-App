import 'dart:io';
import 'dart:typed_data';

class CreateBookModel {
  // Step 1 fields
  File? coverImage;
  String title;
  String targetAudience; // male, female, both
  
  // Step 2 fields
  List<String> genres; // Tags in backend
  List<String> styleLabels; // Labels in backend - style
  List<String> characterLabels; // Labels in backend - character
  List<String> settingLabels; // Labels in backend - setting
  
  // Step 3 fields
  String summary;
  bool isCompleted;
  bool isFree;
  
  // Step 4 fields
  File? pdfFile;
  Uint8List? pdfBytes;
  
  // Other fields
  String? ebookId; // ID of the book being edited
  
  // Constructor
  CreateBookModel({
    this.coverImage,
    this.title = '',
    this.targetAudience = '',
    this.genres = const [],
    this.styleLabels = const [],
    this.characterLabels = const [],
    this.settingLabels = const [],
    this.summary = '',
    this.isCompleted = false,
    this.isFree = true,
    this.pdfFile,
    this.pdfBytes,
    this.ebookId, // Add this line
  });
  
  // Create a copy with modifications
  CreateBookModel copyWith({
    File? coverImage,
    String? title,
    String? targetAudience,
    List<String>? genres,
    List<String>? styleLabels,
    List<String>? characterLabels,
    List<String>? settingLabels,
    String? summary,
    bool? isCompleted,
    bool? isFree,
    File? pdfFile,
    Uint8List? pdfBytes,
    String? ebookId, // Add this line
  }) {
    return CreateBookModel(
      coverImage: coverImage ?? this.coverImage,
      title: title ?? this.title,
      targetAudience: targetAudience ?? this.targetAudience,
      genres: genres ?? this.genres,
      styleLabels: styleLabels ?? this.styleLabels,
      characterLabels: characterLabels ?? this.characterLabels,
      settingLabels: settingLabels ?? this.settingLabels,
      summary: summary ?? this.summary,
      isCompleted: isCompleted ?? this.isCompleted,
      isFree: isFree ?? this.isFree,
      pdfFile: pdfFile ?? this.pdfFile,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      ebookId: ebookId ?? this.ebookId, // Add this line
    );
  }
  
  // Convert to form data for API
  Map<String, dynamic> toFormData() {
    final combinedLabels = [...styleLabels, ...characterLabels, ...settingLabels];
    
    return {
      'title': title,
      'summary': summary,
      'tags': genres,
      'labels': combinedLabels,
      'free': isFree,
      'completed': isCompleted,
      // Note: The files will be handled separately in the repository
      // 'image' and 'pdfFile' will be part of the multipart form data
    };
  }
  
  // Validation methods
  bool isStep1Valid() {
    return coverImage != null && title.isNotEmpty && targetAudience.isNotEmpty;
  }
  
  bool isStep2Valid() {
    return genres.isNotEmpty;
  }
  
  bool isStep3Valid() {
    return summary.isNotEmpty;
  }
  
  bool isStep4Valid() {
    return pdfFile != null || pdfBytes != null;
  }
}