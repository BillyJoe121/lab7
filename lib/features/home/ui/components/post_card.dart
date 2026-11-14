import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:moviles_auth/components/avatar.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/theme/app_theme.dart';

/// Card of one post: author with photo, text, image, date, the heart with its counter
/// and, on the posts of the signed in user, the button to delete it.
class PostCard extends StatelessWidget {
  final Post post;
  final Function() onLike;
  final Function() onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onDelete,
  });

  String _date(DateTime date) {
    final local = date.toLocal();
    final minutes = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month} · ${local.hour}:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                url: post.authorAvatarUrl,
                name: post.authorName,
                size: 36,
              ),
              const SizedBox(width: 10),
              Text(
                '@${post.authorUsername}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  post.authorName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Text(
                _date(post.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 8),
          if (post.content.isNotEmpty)
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          if (post.imageUrl != null) ...[
            const SizedBox(height: 8),
            Container(
              height: 220,
              width: double.infinity,
              margin: const EdgeInsets.only(right: 8),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              // The signed URL changes on every load: the path keeps the cache entry stable.
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                cacheKey: post.imagePath,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),
          ],
          Row(
            children: [
              IconButton(
                onPressed: () => onLike(),
                icon: Icon(
                  post.likedByMe ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.error,
                ),
              ),
              Text('${post.likeCount}'),
              const Spacer(),
              if (post.isMine)
                IconButton(
                  onPressed: () => onDelete(),
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.textSecondary,
                  tooltip: 'Borrar post',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
