import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';
import 'package:novelnooks/src/features/auth/providers/user_provider.dart';

class ReaderService {
  final Ref ref;
  EpubController? _epubController;
  
  ReaderService(this.ref) {
    // Initialize controller
    _epubController = EpubController();
  }
  
  // Get the controller for use in widgets
  EpubController getController() {
    _epubController ??= EpubController();
    return _epubController!;
  }
  
  // Get last reading position
  Future<String?> getLastReadingPosition(String storyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final position = prefs.getString('epub_location_$storyId');
      return position;
    } catch (e) {
      print('Error retrieving last reading position: $e');
      return null;
    }
  }

  // Save reading position
  Future<void> saveReadingPosition(String storyId, String cfi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('epub_location_$storyId', cfi);
      print('Saved reading position: $cfi for story $storyId');
    } catch (e) {
      print('Error saving reading position: $e');
    }
  }

  // Check cached EPUB file
  Future<String?> getCachedEpubPath(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedPath = prefs.getString('epub_$storyId');
    
    if (cachedPath != null) {
      final file = File(cachedPath);
      if (await file.exists()) {
        // Check if we need to update for non-completed books
        final lastCheckStr = prefs.getString('epub_${storyId}_checked');
        if (lastCheckStr != null) {
          final lastCheck = DateTime.parse(lastCheckStr);
          final diff = DateTime.now().difference(lastCheck);
          
          // Only check for updates if it's been more than a day
          if (diff.inDays > 0) {
            final completed = prefs.getBool('epub_${storyId}_completed') ?? false;
            if (!completed) {
              final contentCount = prefs.getInt('epub_${storyId}_contentCount') ?? 0;
              final updates = await checkForUpdates(storyId, contentCount, lastCheck.toIso8601String());
              
              if (updates['hasUpdates'] == true) {
                // Force re-download if there are updates
                return null;
              }
              
              // Update the last check date
              await prefs.setString('epub_${storyId}_checked', DateTime.now().toIso8601String());
            }
          }
        }
        
        return cachedPath;
      }
    }
    
    return null;
  }
  
  // Check if story has updates
  Future<Map<String, dynamic>> checkForUpdates(
      String storyId, int lastContentCount, String lastCheckDate) async {
    try {
      final response = await DioConfig.dio?.get(
        '/ebook/$storyId/check-updates',
        queryParameters: {
          'lastContentCount': lastContentCount,
          'lastCheckDate': lastCheckDate,
        },
      );
      
      if (response?.statusCode == 200) {
        return response?.data;
      }
      return {'hasUpdates': false};
    } catch (e) {
      print('Error checking for updates: $e');
      return {'hasUpdates': false};
    }
  }
  
  // Download EPUB file
  Future<String> downloadEpubFile(
    String storyId, 
    String title,
    bool completed,
    void Function(double progress)? onProgress
  ) async {
    try {
      // Get app directory for storing downloaded files
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${storyId.replaceAll("/", "_")}.epub';
      final filePath = '${appDir.path}/$fileName';
      
      // Create download options
      final downloadOptions = Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 2),
      );
      
      // Download file
      final response = await DioConfig.dio?.get(
        '/ebook/$storyId',
        options: downloadOptions,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );
      
      if (response?.statusCode == 200) {
        // Save file to disk
        final file = File(filePath);
        await file.writeAsBytes(response!.data);
        
        // Save path to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('epub_$storyId', filePath);
        await prefs.setString('epub_${storyId}_checked', DateTime.now().toIso8601String());
        await prefs.setBool('epub_${storyId}_completed', completed);
        
        // Return the full path to the file
        return filePath;
      }
      
      throw Exception('Failed to download EPUB file: ${response?.statusCode}');
    } catch (e) {
      print('Error downloading EPUB: $e');
      throw Exception('Error downloading EPUB file: $e');
    }
  }
  
  // Check if user can read full story
  Future<bool> canReadFullStory(String storyId, bool isFree, int contentCount, double pricePerChapter) async {
    final userState = ref.read(userProvider).valueOrNull;
    
    // Free stories can be read by anyone
    if (isFree) return true;
    
    // Premium users can read everything
    if (userState?.isPremium == true) return true;
    
    // Calculate total cost
    final totalCost = contentCount * pricePerChapter;
    
    // Check if user has enough coins
    return (userState?.coins ?? 0) >= totalCost;
  }
  
  // Process payment for a story
  Future<bool> processStoryPayment(String storyId, double totalCost) async {
    try {
      final response = await DioConfig.dio?.post(
        '/user/purchase-story',
        data: {
          'storyId': storyId,
          'amount': totalCost,
        },
      );
      
      return response?.statusCode == 200;
    } catch (e) {
      print('Error processing payment: $e');
      return false;
    }
  }
}

final readerServiceProvider = Provider<ReaderService>((ref) {
  return ReaderService(ref);
});