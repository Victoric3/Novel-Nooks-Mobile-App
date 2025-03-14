import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';

/// Status of sections for a specific eBook
class SectionStatus {
  final int sectionCount;
  final String status;
  final String? processingStatus;
  final bool needsUpdate;
  
  SectionStatus({
    required this.sectionCount,
    required this.status,
    this.processingStatus,
    required this.needsUpdate,
  });
  
  factory SectionStatus.fromJson(Map<String, dynamic> json) {
    return SectionStatus(
      sectionCount: json['sectionCount'] ?? 0,
      status: json['status'] ?? 'processing',
      processingStatus: json['processingStatus'],
      needsUpdate: json['needsUpdate'] ?? true,
    );
  }
}

/// Repository for managing eBook sections with local caching
class EbookSectionsRepository {
  final Ref ref;
  
  EbookSectionsRepository(this.ref);

  /// Check if sections need to be updated
  Future<SectionStatus> checkSectionsStatus(String ebookId) async {
    try {
      final response = await DioConfig.dio?.get('/ebook/$ebookId/sections-count');
      
      if (response?.statusCode == 200 && response?.data['success'] == true) {
        return SectionStatus.fromJson(response!.data['data']);
      } else {
        throw Exception('Failed to check section status: ${response?.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking section status: $e');
    }
  }

  /// Fetch sections from server with progress tracking
  Future<EbookModel> fetchSections(
    String ebookId, {
    Function(double, int, int)? onProgress, // Update signature to include total bytes
  }) async {
    try {
      // Track the response size to calculate progress
      final response = await DioConfig.dio?.get(
        '/ebook/$ebookId/sections',
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total, received, total); // Pass total bytes to callback
          }
        },
      );
      
      if (response?.statusCode == 200 && response?.data['success'] == true) {
        final ebookData = response?.data['data'];
        
        // Create a minimal EbookModel with only the necessary sections data
        final ebook = EbookModel(
          id: ebookData['_id'] ?? ebookId,
          title: ebookData['title'] ?? 'Unknown',
          slug: ebookData['slug'],
          author: 'Author', // Not critical for reader
          createdAt: DateTime.now(),
          status: 'complete',
          sections: (ebookData['sections'] as List?)?.map((section) => 
              Map<String, dynamic>.from(section)).toList(),
          contentTitles: (ebookData['contentTitles'] as List?)?.map((title) => 
              Map<String, dynamic>.from(title)).toList(),
        );
        
        // Save to local storage
        await _saveSectionsToLocalStorage(ebookId, ebookData);
        
        return ebook;
      } else {
        throw Exception('Failed to fetch sections: ${response?.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sections: $e');
    }
  }

  /// Save sections to local storage
  Future<void> _saveSectionsToLocalStorage(String ebookId, Map<String, dynamic> data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/ebook_sections_$ebookId.json');
      
      // First delete the existing file if it exists
      if (await file.exists()) {
        await file.delete();
      }
      
      // Add timestamp to know when it was last updated
      final dataToSave = {
        ...data,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Create a new file with fresh data
      await file.writeAsString(jsonEncode(dataToSave));
    } catch (e) {
      print('Error saving sections to storage: $e');
      // Non-critical error - we can still proceed with in-memory data
    }
  }

  /// Check if sections exist in local storage
  Future<bool> hasCachedSections(String ebookId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/ebook_sections_$ebookId.json');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Load sections from local storage
  Future<EbookModel?> loadSectionsFromLocalStorage(String ebookId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/ebook_sections_$ebookId.json');
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        
        // Create a minimal EbookModel with only the necessary sections data
        return EbookModel(
          id: data['_id'] ?? ebookId,
          title: data['title'] ?? 'Unknown',
          slug: data['slug'],
          author: 'Author', // Not critical for reader
          createdAt: DateTime.now(),
          status: 'complete',
          sections: (data['sections'] as List?)?.map((section) => 
              Map<String, dynamic>.from(section)).toList(),
          contentTitles: (data['contentTitles'] as List?)?.map((title) => 
              Map<String, dynamic>.from(title)).toList(),
        );
      }
      return null;
    } catch (e) {
      print('Error loading sections from storage: $e');
      return null;
    }
  }
}