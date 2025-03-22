import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';
import 'package:novelnooks/src/features/auth/providers/user_provider.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryRepository {
  final Ref ref;

  LibraryRepository(this.ref);

  Future<Map<String, dynamic>> fetchUserEbooks({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    String? filterBy,
  }) async {
    try {
      // Build query parameters matching the backend `getEbooksForUser` expectations
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (searchQuery != null && searchQuery.isNotEmpty) 'searchQuery': searchQuery,
        if (filterBy != null && filterBy.isNotEmpty && filterBy != 'all') 'filterBy': filterBy,
      };

      final response = await DioConfig.dio?.get(
        '/ebook/user/get',
        queryParameters: queryParams,
      );

      if (response?.statusCode == 200 && response?.data['success'] == true) {
        // Extract data assuming response structure is { success: true, data: { ebooks, pagination } }
        final dynamic responseData = response?.data;
        if (responseData == null) {
          throw Exception('No data returned from server');
        }

        // Parse ebooks
        final dynamic ebooksData = responseData['data'];
        final List<EbookModel> ebooks = ebooksData is List
            ? ebooksData.map((json) => EbookModel.fromJson(json)).toList()
            : [];

        // Parse pagination
        final paginationData = responseData['pagination'];
        final PaginationModel pagination = paginationData != null
            ? PaginationModel(
                currentPage: paginationData['currentPage'] ?? 1,
                totalPages: paginationData['totalPages'] ?? 1,
                totalEbooks: paginationData['totalEbooks'] ?? 0,
                hasMore: paginationData['hasMore'] ?? false,
              )
            : const PaginationModel(
                currentPage: 1,
                totalPages: 1,
                totalEbooks: 0,
                hasMore: false,
              );

        return {
          'ebooks': ebooks,
          'pagination': pagination,
        };
      } else {
        throw Exception('Failed to fetch user ebooks: ${response?.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching user ebooks: $e');
    }
  }

  /// Fetches all ebooks based on the `getAllStories` controller.
  /// Uses a GET request to '/ebook/' with query parameters as per the controller.
  Future<Map<String, dynamic>> fetchAllEbooks({
    bool specific = false,
    String? slug,
    String? searchQuery,
    String? authorUsername,
    String? tags,
    String? free,
    String? completed,
    String? minRating,
    String? minLikes,
    String? section,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Build query parameters matching `getAllStories` expectations
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (specific) 'specific': 'true',
        if (slug != null && slug.isNotEmpty) 'slug': slug,
        if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
        if (authorUsername != null && authorUsername.isNotEmpty) 'author': authorUsername,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
        if (free != null) 'free': free,
        if (completed != null) 'completed': completed,
        if (minRating != null && minRating.isNotEmpty) 'minRating': minRating,
        if (minLikes != null && minLikes.isNotEmpty) 'minLikes': minLikes,
        if (section != null && section.isNotEmpty) 'section': section,
      };
      final userModel = ref.read(userProvider).valueOrNull;
      final String? currentUserId = userModel?.id;

      // Make API call - GET request as per route `router.get("/", getAllStories)`
      final response = await DioConfig.dio?.get(
        '/ebook/',
        queryParameters: queryParams,
      );

      if (response?.statusCode == 200 && response?.data['success'] == true) {
        // Parse response: { success: true, count, data, page, pages, total }
        final dynamic ebooksData = response?.data['data'];
        final List<EbookModel> ebooks = ebooksData is List
            ? ebooksData.map((json) => EbookModel.fromJson(json, currentUserId: currentUserId)).toList()
            : [];

        final int total = response?.data['total'] ?? 0;
        final int totalPages = response?.data['pages'] ?? 1;
        final int currentPage = response?.data['page'] ?? 1;
        final bool hasMore = currentPage < totalPages;

        return {
          'ebooks': ebooks,
          'pagination': PaginationModel(
            currentPage: currentPage,
            totalPages: totalPages,
            totalEbooks: total,
            hasMore: hasMore,
          ),
        };
      } else {
        throw Exception('Failed to fetch all ebooks: ${response?.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching all ebooks: $e');
    }
  }

  Future<EbookModel> fetchEbookDetails({String? id, String? slug}) async {
    final userModel = ref.read(userProvider).valueOrNull;
    final String? currentUserId = userModel?.id;

    try {
      if (id == null && slug == null) {
        throw Exception('Either ID or slug must be provided');
      }

      final String endpoint = id != null
          ? '/ebook/${slug ?? "detail"}?id=$id'
          : '/ebook/$slug';

      final response = await DioConfig.dio?.get(endpoint);

      if (response?.statusCode == 200 && response?.data['success'] == true) {
        final dynamic ebookData = response?.data['data'];
        if (ebookData == null) {
          throw Exception('Ebook data not found');
        }

        final Map<String, dynamic> processedData = Map<String, dynamic>.from(ebookData);

        if (userModel != null && processedData['isInReadingList'] == null) {
          try {
            final checkResponse = await DioConfig.dio?.get('/user/readList/check/$id');
            if (checkResponse?.statusCode == 200) {
              processedData['isInReadingList'] = checkResponse?.data['isInReadList'] ?? false;
            }
          } catch (e) {
            print('Error checking reading list status: $e');
            processedData['isInReadingList'] = false;
          }
        }

        return EbookModel.fromJson(processedData, currentUserId: currentUserId);
      } else {
        throw Exception(
          response?.data?['message'] ?? 'Failed to fetch ebook details: ${response?.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching ebook details: $e');
    }
  }

  Future<Map<String, dynamic>> likeEbook(String id) async {
    try {
      final response = await DioConfig.dio?.post('/ebook/$id/like');

      if (response?.statusCode == 200 && response?.data['success'] == true) {
        return {
          'likeStatus': response?.data['likeStatus'] ?? false,
          'data': response?.data['data'] ?? {'likeCount': 0},
        };
      } else {
        throw Exception(response?.data?['errorMessage'] ?? 'Failed to like ebook');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return {
          'likeStatus': true,
          'data': {'likeCount': 0},
          'offline': true,
        };
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error liking ebook: $e');
    }
  }

  Future<EbookModel> rateEbook(String id, int rating) async {
    try {
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      final userModel = ref.read(userProvider).valueOrNull;
      final String? currentUserId = userModel?.id;

      final response = await DioConfig.dio?.put(
        '/ebook/$id/rate',
        data: {'rating': rating},
      );

      if (response?.statusCode == 200 && response?.data['success'] == true) {
        final responseData = response?.data['data'];
        return EbookModel.fromJson({
          '_id': id,
          'averageRating': responseData['averageRating'] ?? 0.0,
          'ratingCount': responseData['ratingCount'] ?? 0,
          'title': '',
          'author': '',
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'complete',
        }, currentUserId: currentUserId);
      } else {
        throw Exception(response?.data?['message'] ?? 'Failed to rate ebook');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return EbookModel.fromJson({
          '_id': id,
          'averageRating': 0.0,
          'ratingCount': 0,
          'title': '',
          'author': '',
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'complete',
        });
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error rating ebook: $e');
    }
  }

  Future<bool> toggleReadingList(String ebookId) async {
    try {
      final response = await DioConfig.dio?.post('/user/$ebookId/addStoryToReadList');
      if (response?.statusCode == 200 && response?.data['success'] == true) {
        return response?.data['status'] ?? false;
      } else {
        throw Exception('Failed to update reading list: ${response?.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating reading list: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserFavorites({
    int page = 1,
    int limit = 10,
    String? searchQuery, // Add this parameter
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'pageSize': limit,
        if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery, // Add search param
      };

      final userModel = ref.read(userProvider).valueOrNull;
      final String? currentUserId = userModel?.id;

      final response = await DioConfig.dio?.get(
        '/user/favorites',
        queryParameters: queryParams,
      );

      if (response?.statusCode == 200) {
        final dynamic ebooksData = response?.data['data'];
        final List<EbookModel> ebooks = ebooksData is List
            ? ebooksData.map((json) => EbookModel.fromJson(json, currentUserId: currentUserId)).toList()
            : [];

        final paginationData = response?.data['pagination'];
        final PaginationModel pagination = paginationData != null
            ? PaginationModel(
                currentPage: paginationData['currentPage'] ?? 1,
                totalPages: paginationData['totalPages'] ?? 1,
                totalEbooks: paginationData['totalItems'] ?? 0,
                hasMore: (paginationData['currentPage'] ?? 1) < (paginationData['totalPages'] ?? 1),
              )
            : const PaginationModel(
                currentPage: 1,
                totalPages: 1,
                totalEbooks: 0,
                hasMore: false,
              );

        return {
          'ebooks': ebooks,
          'pagination': pagination,
        };
      } else {
        throw Exception('Failed to fetch favorites: ${response?.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching favorites: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserReadList({
    int page = 1,
    int limit = 10,
    String? searchQuery, // Add this parameter
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'pageSize': limit,
        if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery, // Add search param
      };

      final userModel = ref.read(userProvider).valueOrNull;
      final String? currentUserId = userModel?.id;

      final response = await DioConfig.dio?.get(
        '/user/readList',
        queryParameters: queryParams,
      );

      if (response?.statusCode == 200) {
        final dynamic ebooksData = response?.data['data'];
        final List<EbookModel> ebooks = ebooksData is List
            ? ebooksData.map((json) => EbookModel.fromJson(json, currentUserId: currentUserId)).toList()
            : [];

        final paginationData = response?.data['pagination'];
        final PaginationModel pagination = paginationData != null
            ? PaginationModel(
                currentPage: paginationData['currentPage'] ?? 1,
                totalPages: paginationData['totalPages'] ?? 1,
                totalEbooks: paginationData['totalItems'] ?? 0,
                hasMore: (paginationData['currentPage'] ?? 1) < (paginationData['totalPages'] ?? 1),
              )
            : const PaginationModel(
                currentPage: 1,
                totalPages: 1,
                totalEbooks: 0,
                hasMore: false,
              );

        return {
          'ebooks': ebooks,
          'pagination': pagination,
        };
      } else {
        throw Exception('Failed to fetch reading list: ${response?.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching reading list: $e');
    }
  }


  Future<Uint8List> fetchEbookFile(String fileUrl, {Function(double, int)? onProgress}) async {
    try {
      final response = await DioConfig.dio?.get(
        '/ebook/ebookfile/fetch',
        queryParameters: {'fileUrl': fileUrl},
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total, received);
          }
        },
      );

      if (response?.statusCode == 200) {
        return response!.data as Uint8List;
      } else {
        throw Exception('Failed to fetch document: ${response?.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error while downloading document: ${e.message}');
    } catch (e) {
      throw Exception('Error accessing document: $e');
    }
  }

  Future<Map<String, dynamic>> getSearchSuggestions(String query) async {
    try {
      final response = await DioConfig.dio?.get(
        '/search/searchSuggestion',
        queryParameters: {
          'q': query,
          'limit': 10,
        },
      );
      
      if (response?.statusCode == 200) {
        return response?.data;
      } else {
        throw Exception('Failed to fetch search suggestions');
      }
    } catch (e) {
      throw Exception('Failed to fetch search suggestions: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> searchEbooks({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // The backend uses 'search' as the parameter name for search queries
      // And we already have a method that properly calls this endpoint
      return await fetchAllEbooks(
        searchQuery: query,
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }
}