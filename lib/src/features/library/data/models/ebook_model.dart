import 'package:equatable/equatable.dart';

class EbookModel extends Equatable {
  final String id;
  final String title;
  final String? slug;
  final String? summary;
  final String? image;
  final String author;
  final String authorId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final List<int>? readTime;
  final List<String>? likes;
  final int likeCount;
  final int commentCount;
  final double averageRating;
  final int ratingCount;
  final bool free;
  final num prizePerChapter;
  final bool completed;
  final List<String>? contentTitles;
  final int contentCount;
  final double pricePerChapter;

  // Derived fields (client-side or optional)
  final bool? isLikedByCurrentUser;
  final int? userRating;
  final bool? isInReadingList;

  const EbookModel({
    required this.id,
    required this.title,
    this.slug,
    this.summary,
    this.image,
    required this.author,
    required this.authorId,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.readTime,
    this.likes,
    this.likeCount = 0,
    this.commentCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.free = false,
    this.prizePerChapter = 5,
    this.completed = true,
    this.contentTitles,
    this.isLikedByCurrentUser,
    this.userRating,
    this.isInReadingList,
    this.contentCount = 0,
    this.pricePerChapter = 0.0,
  });

  // copyWith method for easy updates
  EbookModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? summary,
    String? image,
    String? author,
    String? authorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    List<int>? readTime,
    List<String>? likes,
    int? likeCount,
    int? commentCount,
    double? averageRating,
    int? ratingCount,
    bool? free,
    num? prizePerChapter,
    bool? completed,
    List<String>? contentTitles,
    bool? isLikedByCurrentUser,
    int? userRating,
    bool? isInReadingList,
    int? contentCount,
    double? pricePerChapter,
  }) {
    return EbookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      summary: summary ?? this.summary,
      image: image ?? this.image,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      readTime: readTime ?? this.readTime,
      likes: likes ?? this.likes,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      free: free ?? this.free,
      prizePerChapter: prizePerChapter ?? this.prizePerChapter,
      completed: completed ?? this.completed,
      contentTitles: contentTitles ?? this.contentTitles,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      userRating: userRating ?? this.userRating,
      isInReadingList: isInReadingList ?? this.isInReadingList,
      contentCount: contentCount ?? this.contentCount,
      pricePerChapter: pricePerChapter ?? this.pricePerChapter,
    );
  }

  // fromJson factory method to parse server data
  factory EbookModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    // Parse likes
    List<String> likesList = [];
    if (json['likes'] != null) {
      likesList = (json['likes'] as List).map((item) => item.toString()).toList();
    }
    
    // Check both server-provided likeStatus field and likes array
    bool isLiked = json['likeStatus'] ?? 
      (currentUserId != null && likesList.contains(currentUserId));

    // Parse ratings for userRating
    int? userRating;
    if (json['ratings'] != null && currentUserId != null) {
      final userRatingObj = (json['ratings'] as List).firstWhere(
        (rating) => rating['user'].toString() == currentUserId,
        orElse: () => null,
      );
      if (userRatingObj != null) {
        userRating = userRatingObj['rating'];
      }
    }

    // Parse readTime
    List<int>? readTimeList;
    if (json['readTime'] != null) {
      readTimeList = (json['readTime'] as List).map((item) => item as int).toList();
    }

    // Parse contentTitles
    List<String>? contentTitlesList;
    if (json['contentTitles'] != null) {
      contentTitlesList = (json['contentTitles'] as List).map((item) => item.toString()).toList();
    }

    return EbookModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? 'Untitled eBook',
      slug: json['slug'],
      summary: json['summary'],
      image: json['image'],
      author: json['author'] is Map ? json['author']['username'] ?? '' : json['author'] ?? '',
      authorId: json['author'] is Map ? json['author']['_id'] ?? '' : json['authorId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      readTime: readTimeList,
      likes: likesList,
      likeCount: json['likeCount'] ?? likesList.length,
      commentCount: json['commentCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      free: json['free'] ?? false,
      prizePerChapter: json['prizePerChapter'] ?? 5,
      completed: json['completed'] ?? true,
      contentTitles: contentTitlesList,
      isLikedByCurrentUser: isLiked,
      userRating: userRating,
      isInReadingList: json['isInReadingList'] ?? false,
      contentCount: json['contentCount'] ?? 0,
      pricePerChapter: (json['pricePerChapter'] ?? 0.0).toDouble(),
    );
  }

  // Equatable props for equality comparison
  @override
  List<Object?> get props => [
        id,
        title,
        slug,
        summary,
        image,
        author,
        createdAt,
        updatedAt,
        tags,
        readTime,
        likes,
        likeCount,
        commentCount,
        averageRating,
        ratingCount,
        free,
        prizePerChapter,
        completed,
        contentTitles,
        isLikedByCurrentUser,
        userRating,
        isInReadingList,
        contentCount,
        pricePerChapter,
      ];
}

class PaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalEbooks;
  final bool hasMore;

  const PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalEbooks,
    required this.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalEbooks: json['totalEbooks'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }
}