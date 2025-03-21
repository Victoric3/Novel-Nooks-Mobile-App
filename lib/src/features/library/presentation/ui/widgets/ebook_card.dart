import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class EbookCard extends StatelessWidget {
  final EbookModel ebook;

  const EbookCard({
    Key? key,
    required this.ebook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        context.router.push(EbookDetailRoute(id: ebook.id, ebook: ebook));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.neonCyan.withOpacity(0.2)
                : AppColors.brandDeepGold.withOpacity(0.2),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: ebook.image != null && ebook.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: ebook.image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildCoverPlaceholder(isDark),
                        errorWidget: (context, url, error) => _buildCoverPlaceholder(isDark),
                      )
                    : _buildCoverPlaceholder(isDark),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ebook.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created ${timeago.format(ebook.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[850] : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.book_outlined,
          size: 40,
          color: isDark ? Colors.white30 : Colors.black26,
        ),
      ),
    );
  }
}