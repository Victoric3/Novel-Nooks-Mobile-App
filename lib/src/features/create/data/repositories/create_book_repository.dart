import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';
import 'package:novelnooks/src/features/create/data/models/create_book_model.dart';

class CreateBookRepository {
  final Dio _dio;
  
  CreateBookRepository(this._dio);
  
  Future<Map<String, dynamic>> uploadBook(CreateBookModel book) async {
    try {
      // Create form data
      final formData = FormData();
      
      // Add JSON fields
      formData.fields.add(MapEntry('title', book.title));
      formData.fields.add(MapEntry('summary', book.summary));
      formData.fields.add(MapEntry('tags', jsonEncode(book.genres)));
      
      // Combine all label types
      final allLabels = [...book.styleLabels, ...book.characterLabels, ...book.settingLabels];
      formData.fields.add(MapEntry('labels', jsonEncode(allLabels)));
      
      formData.fields.add(MapEntry('free', book.isFree.toString()));
      formData.fields.add(MapEntry('completed', book.isCompleted.toString()));
      
      // Add cover image if available
      if (book.coverImage != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            book.coverImage!.path,
            contentType: MediaType('image', 'jpeg'),
            filename: 'cover.jpg',
          ),
        ));
      }
      
      // Add PDF file if available
      if (book.pdfFile != null) {
        formData.files.add(MapEntry(
          'pdfFile',
          await MultipartFile.fromFile(
            book.pdfFile!.path,
            contentType: MediaType('application', 'pdf'),
            filename: 'book.pdf',
          ),
        ));
      } else if (book.pdfBytes != null) {
        formData.files.add(MapEntry(
          'pdfFile',
          MultipartFile.fromBytes(
            book.pdfBytes!,
            contentType: MediaType('application', 'pdf'),
            filename: 'book.pdf',
          ),
        ));
      }
      
      // Submit the form
      final response = await _dio.post(
        '/ebook',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to upload book: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data?['errorMessage'] ?? e.message;
        throw Exception('Failed to upload book: $errorMessage');
      }
      throw Exception('Failed to upload book: $e');
    }
  }
}

final createBookRepositoryProvider = Provider<CreateBookRepository>((ref) {
  return CreateBookRepository(DioConfig.dio!);
});