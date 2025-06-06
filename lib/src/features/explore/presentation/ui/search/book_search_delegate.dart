import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/router/app_router.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/common/widgets/book_grid_item.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';

class BookSearchDelegate extends SearchDelegate<EbookModel?> {
  final WidgetRef ref;
  final bool isDark;
  final String initialTag;

  BookSearchDelegate({
    required this.ref,
    required this.isDark,
    this.initialTag = '',
    String? hintText,
  }) : super(
    searchFieldLabel: hintText ?? 'Search by title, author, or keyword...',
    // Use only one of these, not both:
    searchFieldStyle: TextStyle(
      color: isDark ? Colors.white70 : Colors.black87,
      fontSize: 16,
    ),
    // Remove the searchFieldDecorationTheme parameter:
    // searchFieldDecorationTheme: InputDecorationTheme(...),
  );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkBg : Colors.white,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
        elevation: 0,
      ),
      // Move the input decoration theme here:
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : Colors.grey,
        ),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<EbookModel>>(
      future: _searchBooks(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 56,
                  color: isDark ? Colors.red.shade300 : Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }
        
        final books = snapshot.data!;
        
        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 56,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return BookGridItem(
              book: book,
              onTap: () {
                close(context, book);
                context.router.push(EbookDetailRoute(
                  id: book.id,
                  slug: book.slug,
                  ebook: book,
                ));
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildSuggestionsList(context);
    }
    
    // Show live search results as suggestions
    return FutureBuilder<List<EbookModel>>(
      future: _searchBooks(query, limit: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
            ),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildSuggestionsList(context);
        }
        
        final suggestions = snapshot.data!;
        
        if (suggestions.isEmpty) {
          return _buildSuggestionsList(context);
        }
        
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final book = suggestions[index];
            return ListTile(
              leading: Container(
                width: 40,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: book.image != null && book.image!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(book.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                child: book.image == null || book.image!.isEmpty
                    ? Icon(
                        Icons.book,
                        color: isDark ? Colors.white30 : Colors.black26,
                      )
                    : null,
              ),
              title: Text(
                book.title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                book.author,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                query = book.title;
                close(context, book);
                context.router.push(EbookDetailRoute(
                  id: book.id,
                  slug: book.slug,
                  ebook: book,
                ));
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSuggestionsList(BuildContext context) {
    // Popular searches or categories
    final suggestions = [
      'Romance', 'Fantasy', 'Mystery', 'Werewolf',
      'Mafia', 'YA/TEEN', 'Sci-Fi', 'Urban',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ActionChip(
                label: Text(suggestion),
                backgroundColor: isDark 
                    ? Colors.grey.shade800 
                    : Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () {
                  query = suggestion;
                  showResults(context);
                },
              ),
            );
          }).toList(),
        ),
        
        if (initialTag.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Currently Viewing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: ActionChip(
              avatar: Icon(
                Icons.tag,
                size: 16,
                color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
              ),
              label: Text(initialTag),
              backgroundColor: isDark 
                  ? AppColors.neonCyan.withOpacity(0.1) 
                  : AppColors.brandDeepGold.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                fontWeight: FontWeight.bold,
              ),
              onPressed: () {
                query = initialTag;
                showResults(context);
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<List<EbookModel>> _searchBooks(String searchTerm, {int limit = 10}) async {
    if (searchTerm.trim().isEmpty) {
      return [];
    }
    
    try {
      final Map<String, dynamic> queryParams = {
        'q': searchTerm,
        'limit': limit,
      };
      
      // Add tag filter if we have an initial tag
      if (initialTag.isNotEmpty) {
        queryParams['tag'] = initialTag;
      }
      
      final response = await DioConfig.dio!.get(
        '/ebook/search',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> booksJson = response.data['data'];
        return booksJson.map((json) => EbookModel.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }
}